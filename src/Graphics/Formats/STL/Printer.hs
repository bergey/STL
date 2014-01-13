module Graphics.Formats.STL.Printer where

import Data.Text (Text, unpack)
import Text.PrettyPrint

import Graphics.Formats.STL.Types

prettySTL :: STL -> Doc
prettySTL s = vcat [ text "solid " <> (text . unpack $ name s)
                , vcat . map triangle $ triangles s
                , text "endsolid " <> (text . unpack $ name s)
                ]

triangle :: Triangle -> Doc
triangle (Triangle n (a, b, c)) =
    vcat [ text "facet normal" <+> v3 n
         , nest 4 $ vcat [ text "outer loop"
                         , nest 4 $ vcat [vertex a, vertex b, vertex c]
                         , text "endloop"
                         ]
         , text "endfacet"
         ]

vertex :: Vector -> Doc
vertex v = text "vertex" <+> v3 v

v3 :: Vector -> Doc
v3 (x, y, z) = hsep [double x, double y, double z]
