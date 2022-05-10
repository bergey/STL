{-# LANGUAGE OverloadedStrings #-}

module Graphics.Formats.STL.Parser where

import Data.Attoparsec.Text
import Data.Text (Text)
import Graphics.Formats.STL.Types
import Prelude hiding (takeWhile)

-- | A parser from 'Text' with multiple solids defined in the stl
multiSolidParser :: Parser [STL]
multiSolidParser = many' solidParser

-- | Ensure backwards-compatibility
stlParser :: Parser STL
stlParser = solidParser

-- | A parser from 'Text' to the @STL@ type.  The parser should be
-- fairly permissive about whitespace, but has not been tested enough
-- against STL files in the wild.
solidParser :: Parser STL
solidParser = do
  solidName <- nameParser
  solidTris <- many' triangle
  _ <- text ("endsolid " <> solidName)
  return (STL {name = solidName, triangles = solidTris})

nameParser :: Parser Text
nameParser = text "solid " *> takeWhile (inClass " -~") <* skipSpace

triangle :: Parser Triangle
triangle = Triangle <$> ss normalParser <*> loop <* text "endfacet"

loop :: Parser (Vector, Vector, Vector)
loop =
  triple
    <$> (text "outer loop" *> ss vertex)
    <*> ss vertex
    <*> ss vertex
    <* text "endloop"

normalParser :: Parser (Maybe Vector)
normalParser =
  text "facet" *> text "normal" *> do
    n <- v3
    return $ case n of
      (0, 0, 0) -> Nothing
      _ -> Just n

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
