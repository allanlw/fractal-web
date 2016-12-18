var Module={
  logReadFiles: true,
  "print":(function(text){console.log(text)}),
  "printErr":(function(text){console.error(text)}),
  preInit: function() {
    addRunDependency("FRACTAL");
  },
  preRun:(function(){
    FS.writeFile("/input.bin", __INPUT, {'encoding': 'binary'})
  }),
  postRun:(function(){
    var output = null;
    try {
      output = FS.readFile("/output.bin");
    } catch(e) { console.error("No output..?"); }
    postMessage(output);
    close();
  })
};

var __INPUT;

onmessage= (function(e){
  __INPUT=new Int8Array(e.data.input);
  Module.arguments=e.data.arguments;
  console.log("Running fractal...")
  console.log(Module.arguments);
  console.log(__INPUT);
  removeRunDependency("FRACTAL");
});
