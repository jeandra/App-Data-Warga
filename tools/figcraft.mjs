#!/usr/bin/env node
// Kendali FigCraft lewat MCP stdio, tanpa perlu tool MCP OpenCode.
//
// Contoh:
//   node tools/figcraft.mjs status
//   node tools/figcraft.mjs list
//   node tools/figcraft.mjs call inspect_document --params '{"depth":2,"outline":true}'
//   node tools/figcraft.mjs call create_node --params @tools/contoh-node.json
//   node tools/figcraft.mjs shot hasil.png --params '{"ids":[3]}'
//
// Env: FIGCRAFT_CLI, FIGCRAFT_ATTACH (default 127.0.0.1:8765)

import { spawn } from "node:child_process";
import { readFile, writeFile } from "node:fs/promises";

const CLI = process.env.FIGCRAFT_CLI || "C:\\Program Files\\ArtCraft\\FigCraft\\figcraft-cli.exe";
const ATTACH = process.env.FIGCRAFT_ATTACH || "127.0.0.1:8765";

const argv = process.argv.slice(2);
const mode = argv[0] || "status";

function takeOption(name, fallback) {
  const i = argv.indexOf(name);
  if (i === -1) return fallback;
  const value = argv[i + 1];
  argv.splice(i, 2);
  return value ?? fallback;
}

const outPath = takeOption("--out", null);
const paramsArg = takeOption("--params", argv[2]);
const timeoutMs = Number(takeOption("--timeout", "120000"));

async function parseParams(arg) {
  if (!arg) return {};
  if (arg.startsWith("@")) return JSON.parse(await readFile(arg.slice(1), "utf8"));
  return JSON.parse(arg);
}

const child = spawn(CLI, ["mcp", "--attach", ATTACH], {
  stdio: ["pipe", "pipe", "pipe"],
  windowsHide: true,
});

let buffer = "";
let nextId = 1;
const pending = new Map();
let stderrText = "";

child.stdout.setEncoding("utf8");
child.stdout.on("data", (chunk) => {
  buffer += chunk;
  let newline;
  while ((newline = buffer.indexOf("\n")) >= 0) {
    const line = buffer.slice(0, newline).trim();
    buffer = buffer.slice(newline + 1);
    if (!line) continue;
    let message;
    try {
      message = JSON.parse(line);
    } catch {
      continue;
    }
    if (message.id !== undefined && pending.has(message.id)) {
      const { resolve, reject, timer } = pending.get(message.id);
      clearTimeout(timer);
      pending.delete(message.id);
      if (message.error) reject(new Error(JSON.stringify(message.error)));
      else resolve(message.result);
    }
  }
});

child.stderr.setEncoding("utf8");
child.stderr.on("data", (chunk) => {
  stderrText += chunk;
});

function request(method, params) {
  const id = nextId++;
  return new Promise((resolve, reject) => {
    const timer = setTimeout(() => {
      pending.delete(id);
      reject(new Error(`Timeout ${method}. ${stderrText.trim()}`));
    }, timeoutMs);
    pending.set(id, { resolve, reject, timer });
    child.stdin.write(JSON.stringify({ jsonrpc: "2.0", id, method, params }) + "\n");
  });
}

function notify(method, params) {
  child.stdin.write(JSON.stringify({ jsonrpc: "2.0", method, params }) + "\n");
}

function printText(result) {
  const blocks = result?.content ?? [];
  const text = blocks.filter((block) => block.type === "text").map((block) => block.text).join("\n");
  if (result?.isError) {
    console.error(text || "Tool mengembalikan error.");
    process.exitCode = 1;
  } else if (text) {
    console.log(text);
  }
}

try {
  await request("initialize", {
    protocolVersion: "2024-11-05",
    capabilities: {},
    clientInfo: { name: "opencode-figcraft", version: "1.0.0" },
  });
  notify("notifications/initialized", {});

  if (mode === "status") {
    const doc = await request("tools/call", {
      name: "inspect_document",
      arguments: { depth: 1, outline: true },
    });
    const text = doc?.content?.find((block) => block.type === "text")?.text;
    const parsed = text ? JSON.parse(text) : null;
    console.log(
      JSON.stringify(
        parsed
          ? {
              name: parsed.name,
              path: parsed.path,
              dirty: parsed.dirty,
              page: parsed.currentPage,
              pages: parsed.pages?.length,
              frames: parsed.pages?.[0]?.children?.map((child) => `${child.id}: ${child.name} (${child.type})`),
            }
          : doc,
        null,
        2,
      ),
    );
  } else if (mode === "list") {
    const result = await request("tools/list", {});
    for (const tool of result.tools) {
      console.log(`${tool.name} — ${(tool.description || "").split(". ")[0]}`);
    }
  } else if (mode === "call" || mode === "shot") {
    const name = mode === "shot" ? "screenshot" : argv[1];
    if (!name) throw new Error("Sebutkan nama tool: node tools/figcraft.mjs call <tool> --params '{...}'");
    const args = await parseParams(paramsArg);
    const result = await request("tools/call", { name, arguments: args });

    const images = (result?.content ?? []).filter((block) => block.type === "image" && block.data);
    if (images.length) {
      const target = outPath || (mode === "shot" ? argv[1] : null);
      if (target) {
        let index = 0;
        for (const image of images) {
          const file = target.includes("{i}") ? target.replaceAll("{i}", String(index++)) : target;
          await writeFile(file, Buffer.from(image.data, "base64"));
          console.log(`Gambar disimpan: ${file}`);
        }
      } else {
        console.log(`Tool mengembalikan ${images.length} gambar. Pakai --out <file.png> untuk menyimpannya.`);
      }
    }

    printText(result);
  } else {
    throw new Error(`Mode tidak dikenal: ${mode}. Pakai status | list | call | shot.`);
  }
} catch (error) {
  console.error(`ERROR: ${error.message}`);
  process.exitCode = 1;
} finally {
  child.stdin.end();
  setTimeout(() => {
    child.kill();
    process.exit();
  }, 150);
}
