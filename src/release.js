import { fetchModule } from "./fetchWasm.js";
const url = new URL("./wasm/release.wasm", import.meta.url)

function drawBuffer(){
    let buffer = new Uint8ClampedArray( game.memory.buffer, this.offset, this.size.w * this.size.h * 4);
    // console.log(buffer, this.offset)
    let idata = new ImageData(buffer, this.size.w, this.size.h);
    this.ctx.putImageData(idata,0,0);
    // console.log(idata)
}
function bindCanvas(canvas_id){
    this.canvas = document.querySelector(canvas_id)
    this.canvas.width = this.size.w
    this.canvas.height = this.size.h    
    this.ctx = canvas.getContext('2d')
}
function tick(){
    this.offset = game.step();
}
export async function initGame(w,h){
    const rnd = new WebAssembly.Global({ value: "i64", mutable: true }, BigInt(~~(Math.random()*(2**32))));
    let exports = await fetchModule(url,{js:{rnd}})
    let game = {
        size: {w,h},
        ...exports,
        drawBuffer,
        bindCanvas,
        tick,
    }
    console.log('instantiated', game)
    game.offset = game.init(w,h)
    return game
}