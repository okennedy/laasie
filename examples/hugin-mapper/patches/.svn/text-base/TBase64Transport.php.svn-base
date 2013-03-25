<?php
/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements. See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership. The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License. You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *
 * @package thrift.transport
 */

class TBase64Transport extends TTransport {
  protected $decoder_ring = array(
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
    'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
  );
  
  /**
   * Constructor. Optionally pass an initial value
   * for the buffer.
   */
  public function __construct($baseTransport) {
    $this->baseTransport_ = $baseTransport;
  }

  protected $inBuf_ = 0;
  protected $inStep_ = 0;
  protected $readCnt_ = 0;
  protected $readOut_ = 0;
  protected $outBuf_ = '';
  protected $baseTransport_ = null;

  public function isOpen() {
    return $baseTransport->isOpen();
  }

  public function open() {$this->baseTransport_->open();}

  public function close() {$this->baseTransport_->close();}

  public function write($buf) {
    $this->outBuf_ .= $buf;
    while(strlen($this->outBuf) >= 3){
      $this->baseTransport_->write(
        base64_encode(substr($this->outBuf_, 0, 3))
      );
      $this->outBuf_ = substr($this->outBuf_, 3);
    }
  }

  public function read($len) {
    $ret = "";
    while(strlen($ret) < $len){
      $c = $this->read_one();
      if($c == "") { break; }
      $ret .= $c;
    }
    return $ret;
  }
  
  function read_one() {
    if(!$this->buffer_one()) return "";
    switch($this->inStep_){
      case 0:
        if(!$this->buffer_one()) return "";
        $ret = $this->inBuf_ >> 4;
        $this->inBuf_ = $this->inBuf_ & 0x0f;
        break;
      case 1:
        $ret = $this->inBuf_ >> 2;
        $this->inBuf_ = $this->inBuf_ & 0x03;
        break;
      case 2:
        $ret = $this->inBuf_;
        $this->inBuf_ = 0;
        break;
    }
    $this->inStep_ = ($this->inStep_ + 1) % 3;
    $this->readOut_ ++;
    return chr($ret & 0xff);
  }
  
  function buffer_one() {
    try { 
      while(true){
        $val = $this->baseTransport_->read(1);
        $this->readCnt_ ++;
        if($val == "") { return false; }
        $key = array_search($val, $this->decoder_ring);
        if($key){
//          error_log("read: ".$val. " : ".$key);
          $this->inBuf_ = ($this->inBuf_ << 6) + ($key * 1);
          return true;
        } else {
          switch($val){
            case "A":
              $this->inBuf_ = ($this->inBuf_ << 6);
              return true;
            case "-":
              $this->inBuf_ = ($this->inBuf_ << 6) + 62;
              return true;
            case "_":
              $this->inBuf_ = ($this->inBuf_ << 6) + 63;
              return true;
          }
        }
      }
    } catch(TException $e){
      error_log("unable to read more (read ".($this->readCnt_)." -> ".($this->readOut_)." so far)");
      throw $e;
    }
  }

  function getInBuffer() {
    return $this->inBuf_;
  }

  function getOutBuffer() {
    return $this->outBuf_;
  }

  public function available() {
    return strlen($this->inBuf_);
  }
  
  public function flush() {
    $encoded = base64_encode($this->outBuf_);
    while(strlen($encoded) % 4){
      $encoded .= '=';
    }
    $this->baseTransport_->write($encoded);
    $this->baseTransport_->flush();
    $this->outBuf_ = '';
  }  
}

?>
