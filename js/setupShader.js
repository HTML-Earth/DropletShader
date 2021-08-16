"use strict";
const gl = twgl.getContext(document.getElementById("c"));

console.log("using:" + gl.getParameter(gl.VERSION));  // eslint-disable-line

if (!twgl.isWebGL2(gl)) {
    alert("Sorry, this shader requires WebGL 2.0");  // eslint-disable-line
}

// FETCH LOCAL SHADER FILES
var list = [];
var shaders = ['./shaders/vert.glsl', './shaders/common.glsl', './shaders/buffer.glsl', './shaders/frag.glsl'];

const vs = 0;
const common = 1;
const buffer = 2;
const frag = 3;
var results = [];

shaders.forEach(function(url, i) {
    list.push(
        fetch(url)
            .then(response => response.text())
                .then(data => {results[i] = data;})
    );
});

Promise
    .all(list)
    .then(function() {
        // When all shaders are fetched, load the runShader script
        var script = document.createElement('script');
        script.src = 'js/runShader.js';
        var head = document.getElementsByTagName("head")[0];
        head.appendChild(script);
    });
