// TypedData gets converted to ArrayBuffer in Dartium.
function setTypedData(arrayBuffer, offset) {
  if (typeof(arrayBuffer.buffer) !== 'undefined') {
    arrayBuffer = arrayBuffer.buffer;
  }
  var bytes = new Uint8Array(arrayBuffer);
  Module['HEAPU8'].set(bytes, offset);
}
Module['setTypedData'] = setTypedData;

function getFloat64Array(ptr, length) {
  var bufView = new Float64Array(Module['buffer'], ptr, length);
  return bufView;
}
Module['getFloat64Array'] = getFloat64Array;
