{-# LANGUAGE OverloadedStrings #-}

module Graphics.Formats.STL.Binary () -- export only instances
       where

import           Graphics.Formats.STL.Types
import           Data.Word
import           Control.Applicative
import           Control.Monad
import           Data.Serialize
import qualified Data.Text as T
import qualified Data.ByteString as BS
import           Data.Text.Encoding

instance Serialize Triangle where
    get = Triangle <$> getNormal <*> t <* skip 2 where
      t = (,,) <$> getVector <*> getVector <*> getVector
    put (Triangle n (a, b, c)) = maybeNormal n *> v3 a *> v3 b *> v3 c *> put (0x00 :: Word16)

instance Serialize STL where
    get = do
        _  <- getHeader
        ct <- getWord32le
        STL "" <$> replicateM (fromIntegral ct) get
    put (STL n tris) = put (header n) *> putWord32le ct *> mapM_ put tris where
      ct :: Word32
      ct = fromIntegral . length $ tris  -- here's the space leak

-- | header is always exactly 80 characters long
header :: T.Text -> BS.ByteString
header n = BS.concat [lib, truncatedName, padding] where
  lib = encodeUtf8 "http://hackage.haskell.org/package/STL "
  truncatedName = BS.take (72 - BS.length lib) . encodeUtf8 $ n
  padding = BS.replicate (72 - BS.length truncatedName - BS.length lib) 0x20
-- header _ = BS.replicate 72 0x20 -- cereal adds 8 bytes giving the length of the BS

putFloat :: Float -> Put
putFloat = putFloat32le

v3 :: Vector -> PutM ()
v3 (x,y,z) = putFloat x *> putFloat y *> putFloat z

maybeNormal :: Maybe Vector -> PutM ()
maybeNormal n = case n of
    Nothing -> v3 (0,0,0)
    Just n' -> v3 n'

getHeader :: Get ()
getHeader = skip 80

getFloat :: Get Float
getFloat = getFloat32le

getVector :: Get Vector
getVector = (,,) <$> getFloat <*> getFloat <*> getFloat

getNormal :: Get (Maybe Vector)
getNormal = do
    v <- getVector
    return $ case v of
        (0,0,0) -> Nothing
        n'      -> Just n'
