export async function instantiate(module, imports = {}) {
    const { exports } = await WebAssembly.instantiate(module, imports);
    return exports;
}
export async function fetchModule(url, imports = {}) {
    let module = await globalThis.WebAssembly.compileStreaming(globalThis.fetch(url)); 
    return await instantiate(module, imports)
}