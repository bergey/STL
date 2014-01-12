{-# LANGUAGE OverloadedStrings #-}

module Graphics.Formats.STL.Parser where

import Control.Applicative
import Data.Attoparsec.Text
import Linear

import Graphics.Formats.STL.Types

parser :: Parser STL
parser = STL <$> name <*> many' triangle

name :: Parser Text
name = text "solid" *> takeWhile (inClass " -~")

triangle = Triangle <$> ss normal <*> loop

loop = V3 <$> (text "outer loop" *> ss vertex) <*> ss vertex <*> ss vertex

normal :: Parser Vector
normal = text "facet" *> text "normal" *> v3

vertex :: Parser Vector
vertex = text "vertex" *> v3

v3 :: Parser Vector
v3 = V3 <$> ss double <*> ss double <*> ss double

ss :: Parser a -> Parser a
ss p = p <* skipSpace

text :: Text -> Parser Text
text t = string t <* skipSpace
