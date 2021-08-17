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

// default uniform values
var u_frameRate = 15;
var u_startPause = 0.5;
var u_duration = 3.5;
var u_endPause = 0.5;
var u_dropCount = 4;
var u_dropTimings = [0.2, 0.4, 0.6, 0.8];
var u_dropPositions = [0.5, 0.9, 0.2, 0.1, 0.5, 0.5, 0.8, 0.1]; //x1, y1, x2, y2, etc.
var u_warpAmount = 6;
var u_bg_a = "textures/black.jpg";
var u_bg_b = "textures/bg_b.jpg";


// fetch custom uniform values from url
var url = window.location.href;
var uniformString = url.substr(url.lastIndexOf('?') + 1);

uniformString.split("&").forEach(element => {
    var cmd = element.split("=");
    var varName = cmd[0];
    var newValue = cmd[1];

    switch(varName) {
        case "frameRate":
            u_frameRate = parseFloat(newValue);
            break;
        case "startPause":
            u_startPause = parseFloat(newValue);
            break;
        case "duration":
            u_duration = parseFloat(newValue);
            break;
        case "endPause":
            u_endPause = parseFloat(newValue);
            break;
        case "dropCount":
            u_dropCount = parseInt(newValue);
            break;
        case "warpAmount":
            u_warpAmount = parseFloat(newValue);
            break;
        //case "bg_a":
        //    u_bg_a = newValue;
        //    break;
        //case "bg_b":
        //    u_bg_b = newValue;
        //    break;
        case "drop0": case "drop1": case "drop2": case "drop3":
            var dropIndex = varName.substr(4);
            commaSeparatedValues = newValue.split(",")
            u_dropTimings[parseInt(dropIndex)] = parseFloat(commaSeparatedValues[0]);
            u_dropPositions[parseInt(dropIndex)] = parseFloat(commaSeparatedValues[1]);
            u_dropPositions[parseInt(dropIndex+1)] = parseFloat(commaSeparatedValues[2]);
            break;
        case "bg_a":
            if (newValue == "true")
                u_bg_a = "textures/bg_a.jpg";
        case "bg_b":
            if (newValue == "false")
                u_bg_b = "textures/black.jpg";
    }
});

const texBackgroundA = twgl.createTexture(gl, {src: u_bg_a, flipY: 1, wrap: gl.CLAMP_TO_EDGE});
const texBackgroundB = twgl.createTexture(gl, {src: u_bg_b, flipY: 1, wrap: gl.CLAMP_TO_EDGE});

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
        iResolution: [gl.canvas.width, gl.canvas.height],
        iTime: time * 0.001,
        backgroundA: texBackgroundA,
        backgroundB: texBackgroundB,
        frameRate: u_frameRate,
        startPause: u_startPause,
        duration: u_duration,
        endPause: u_endPause,
        dropCount: u_dropCount,
        dropTimings: u_dropTimings,
        dropPositions: u_dropPositions,
        warpAmount: u_warpAmount,
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
        dropBuffer: fbi.attachments[0]
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