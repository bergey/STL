module Graphics.Formats.STL.Types where

import Data.Text (Text)

data STL = STL { name :: Text
               , triangles :: [Triangle]
               }

data Triangle = Triangle { normal :: Vector
                         , vertices :: (Vector, Vector, Vector)
                         }

type Vector = (Double, Double, Double)

triple :: a -> a -> a -> (a, a, a)
triple a b c = (a, b, c)
