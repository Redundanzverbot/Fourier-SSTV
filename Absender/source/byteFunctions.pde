

// Fügt ein byte-Array aus einem String zusammen (big endian)
byte[] stringToBE(String s){
  
  byte[] block = new byte[s.length()];
  
  for (int i = 0; i < block.length; i++){
    block[i] = byte(s.charAt(i));
  }
  
  return block;
}


// Fügt einen Integer in ein Byte-Array ein (little endian)
byte[] intToLE(int i, int byteAmount){
  
  byte[] block = new byte[byteAmount];
  
  for (int b = byteAmount - 1; b >= 0; b--){
    int byteVal = floor(i / pow(2, 8 * b));
    block[b] = byte(byteVal);
    i -= byteVal * pow(2, 8 * b);
  }
  
  return block;
}


// Fügt einen Byte-Block in ein Byte-Array ein
byte[] insert(byte[] origin, byte[] block, int start){
  
  for (int i = 0; i < block.length; i++){
    origin[start + i] = block[i];
  }
  
  return origin;
}
