const vertexShader = results[vs];
const bufferShader = ''.concat(results[common], results[buffer]);
const fragmentShader = ''.concat(results[common], results[frag]);

const bufferProgram = twgl.createProgramInfo(gl, [vertexShader, bufferShader]);
const fragmentProgram = twgl.createProgramInfo(gl, [vertexShader, fragmentShader]);

const arrays = {
    position: [-1, -1, 0,
                1, -1, 0,
               -1,  1, 0,
               -1,  1, 0,
                1, -1, 0,
                1,  1, 0],
};

const bufferInfo = twgl.createBufferInfoFromArrays(gl, arrays);

const texBackgroundA = twgl.createTexture(gl, {src: "bg_a_hd.png", flipY: 1, wrap: gl.CLAMP_TO_EDGE});
const texBackgroundB = twgl.createTexture(gl, {src: "bg_b_hd.png", flipY: 1, wrap: gl.CLAMP_TO_EDGE});

//const texBuffer = twgl.createTexture(gl, {src: "bg_a.jpg"});

const attachments = [
  {format: gl.RGBA, level: 0}
]

const fbi = twgl.createFramebufferInfo(gl, attachments, gl.canvas.width, gl.canvas.height);

requestAnimationFrame(render);

function render(time) {
    if (twgl.resizeCanvasToDisplaySize(gl.canvas)) {
        gl.viewport(0, 0, gl.canvas.width, gl.canvas.height);
        
        // resize the attachments
        twgl.resizeFramebufferInfo(gl, fbi, attachments);
    }

    const uniforms = {
        //iTime: time * 0.001,
        iTime: 1.69,
        iResolution: [gl.canvas.width, gl.canvas.height],
        backgroundA: texBackgroundA,
        backgroundB: texBackgroundB
    };
    
    // Render to buffer texture
    {
        gl.useProgram(bufferProgram.program);
        twgl.setBuffersAndAttributes(gl, bufferProgram, bufferInfo);
        twgl.setUniforms(bufferProgram, uniforms);
        
        twgl.bindFramebufferInfo(gl, fbi);
        twgl.drawBufferInfo(gl, bufferInfo);
    }
    
    const bufferTexUniform = {
        buffer: fbi.attachments[0]
    };


    // Render final output
    {
        gl.useProgram(fragmentProgram.program);
        twgl.setBuffersAndAttributes(gl, fragmentProgram, bufferInfo);
        twgl.setUniforms(fragmentProgram, uniforms);
        twgl.setUniforms(fragmentProgram, bufferTexUniform);
                
        twgl.bindFramebufferInfo(gl, null)
        twgl.drawBufferInfo(gl, bufferInfo);
    }

  requestAnimationFrame(render);
}

function fetchLocal(url) {
    return new Promise(function (resolve, reject) {
        var xhr = new XMLHttpRequest
        xhr.onload = function () {
            resolve(new Response(xhr.response, { status: xhr.status }))
        }
        xhr.onerror = function () {
            reject(new TypeError('Local request failed'))
        }
        xhr.open('GET', url)
        xhr.responseType = "arraybuffer";
        xhr.send(null)
    })
};