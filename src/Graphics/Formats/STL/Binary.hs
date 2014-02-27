{-# LANGUAGE OverloadedStrings #-}

module Graphics.Formats.STL.Binary where

import Graphics.Formats.STL.Types
import Data.Word
import           Control.Applicative
import           Data.Serialize
import           Data.Serialize.IEEE754
import qualified Data.Text as T
import qualified Data.ByteString as BS
import           Data.Text.Encoding

instance Serialize Triangle where
    get = undefined
    put (Triangle n (a, b, c)) = maybeNormal n *> v3 a *> v3 b *> v3 c *> put (0x00 :: Word16)

instance Serialize STL where
    get = undefined
    put (STL name tris) = put (header name) *> putWord32le ct *> mapM_ put tris where
      ct :: Word32
      ct = fromIntegral . length $ tris  -- here's the space leak

-- | header is always exactly 80 characters long
header :: T.Text -> BS.ByteString
header name = BS.concat [lib, truncatedName, padding] where
  lib = encodeUtf8 "http://hackage.haskell.org/package/STL "
  truncatedName = BS.take (72 - BS.length lib) . encodeUtf8 $ name
  padding = BS.replicate (72 - BS.length truncatedName - BS.length lib) 0x20
-- header _ = BS.replicate 72 0x20 -- cereal adds 8 bytes giving the length of the BS

float = putFloat32le

v3 (x,y,z) = float x *> float y *> float z

maybeNormal n = case n of
    Nothing -> v3 (0,0,0)
    Just n' -> v3 n'
