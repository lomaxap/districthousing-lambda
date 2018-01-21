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
      var fileSize = Math.round(bytes/10000)/100 + 'mbs';
      if(bytes > 5999999){
        callback(null, { status: 'FAILURE', building: event.form.name, fileSize: fileSize, code: code, errorMessage: "PDF must be smaller than 6mbs. Was " + fileSize + '. Please upload a smaller PDF.', pdf: ''});
      } else {
        callback(null, { status: 'OK', building: event.form.name, fileSize: fileSize, code: code, errorMessage: "", pdf: pdf});
      }
    } else {
      callback(null, { status: 'FAILURE', building: event.form.name, fileSize: fileSize, code: code, errorMessage: getError(err), pdf: '' });
    }
  });
}


function getError(err){
  let match = err.match(/<error>(.+)<\/error>/);
  if(match.length > 0) return match[1];
  return err;
}
