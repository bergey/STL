{-# LANGUAGE OverloadedStrings #-}

module Graphics.Formats.STL.Printer where

import qualified Data.ByteString as BS
import           Data.ByteString.Builder
import           Data.List (intersperse)
import           Data.Monoid
import           Data.Text.Encoding (encodeUtf8)

import           Graphics.Formats.STL.Types

-- | Convert an @STL@ value to a @Builder@, which can be converted to a
-- @ByteString@ with 'toLazyByteString'
textSTL :: STL -> Builder
textSTL s = vcat [ stringUtf8 "solid " <> (byteString . encodeUtf8 $ name s)
                   , vcat . map triangle $ triangles s
                   , stringUtf8 "endsolid " <> (byteString . encodeUtf8 $ name s)
                   ]

triangle :: Triangle -> Builder
triangle (Triangle n (a, b, c)) =
    vcat $ stringUtf8 "facet normal " <> maybeNormal n :
           map (indent 4) [ stringUtf8 "outer loop"
                           , indent 4 $ vertex a
                           , indent 4 $ vertex b
                           , indent 4 $ vertex c
                           , stringUtf8 "endloop"
                           ]
         ++ [stringUtf8 "endfacet"]

maybeNormal :: Maybe Vector -> Builder
maybeNormal n = case n of
    Nothing -> v3 (0,0,0)
    Just n' -> v3 n'

vertex :: Vector -> Builder
vertex v = stringUtf8 "vertex " <> v3 v

v3 :: Vector -> Builder
v3 (x, y, z) = mconcat $ intersperse space [floatDec x, floatDec y, floatDec z]
  where
    space = charUtf8 ' '

indent :: Int -> Builder -> Builder
indent i bs = spaces <> bs where
  spaces  = byteString . BS.replicate i $ 0x20 -- 0x20 is UTF-8 space

vcat :: [Builder] -> Builder
vcat bs = mconcat $ intersperse newline bs where
  newline = charUtf8 '\n'
