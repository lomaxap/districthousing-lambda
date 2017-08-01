var spawn = require('child_process').spawn;
var app = "./app";

exports.handler = function(event, context, callback) {
  var pdfGen = spawn(app, [JSON.stringify(event, null, 2)]);
  var pdf = ''
  var err = ''

  pdfGen.stdout.on('data', function(data){
    pdf += data;
  });

  pdfGen.stderr.on('data', function(data){
    err += data;
  });

  pdfGen.on('close', function (code) {
    if(code === 0) {
      callback(null, { status: 'OK', pdf: pdf });
    } else {
      callback(null, { status: 'FAILURE', code: code, error: err });
    }
  });
}
