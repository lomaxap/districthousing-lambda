var spawn = require('child_process').spawn;
var app = "./app";

exports.handler = function(event, context, callback) {
  var pdfGen = spawn(app, [JSON.stringify(event, null, 2)]);
  var pdf = '';
  var err = '';

  pdfGen.stdout.on('data', function(data){
    pdf += data;
  });

  pdfGen.stderr.on('data', function(data){
    err += data;
  });

  pdfGen.on('close', function (code) {
    if(code===0) {
      var bytes = Buffer.byteLength(pdf, 'utf8');
      if(bytes > 5999999){
        callback(null, { status: 'FAILURE', pdf: '', code: code, errorMessage: "PDF must be smaller than 6mbs. Was " + Math.round(bytes/10000)/100 + 'mbs. Please upload a smaller PDF.', building: event.form.name });
      } else {
        callback(null, { status: 'OK', pdf: pdf, code: code, errorMessage: "", building: event.form.name });
      }
    } else {
      callback(null, { status: 'FAILURE', pdf: '', code: code, errorMessage: err, building: event.form.name });
    }
  });
}
