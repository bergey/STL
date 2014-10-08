{-# LANGUAGE OverloadedStrings #-}

module Graphics.Formats.STL.Parser where

import Prelude hiding (takeWhile)

import Control.Applicative
import Data.Attoparsec.Text
import Data.Text (Text)

import Graphics.Formats.STL.Types

-- | A parser from 'Text' to the @STL@ type.  The parser should be
-- fairly permissive about whitespace, but has not been tested enough
-- against STL files in the wild.
stlParser :: Parser STL
stlParser = STL <$> nameParser <*> many' triangle

nameParser :: Parser Text
nameParser = text "solid" *> takeWhile (inClass " -~") <* skipSpace

triangle :: Parser Triangle
triangle = Triangle <$> ss normalParser <*> loop <* text "endfacet"

loop :: Parser (Vector, Vector, Vector)
loop = triple <$> (text "outer loop" *> ss vertex) <*> ss vertex <*> ss vertex <* text "endloop"

normalParser :: Parser (Maybe Vector)
normalParser = text "facet" *> text "normal" *> do
    n <- v3
    return $ case n of
        (0, 0, 0) -> Nothing
        _         -> Just n

vertex :: Parser Vector
vertex = text "vertex" *> v3

v3 :: Parser Vector
v3 = triple <$> ss float <*> ss float <*> ss float

ss :: Parser a -> Parser a
ss p = p <* skipSpace

text :: Text -> Parser Text
text t = string t <* skipSpace

float :: Parser Float
float = realToFrac <$> double
