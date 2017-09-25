import           Data.Attoparsec.Text         (parseOnly)
import qualified Data.ByteString.Lazy         as BS
import           Data.ByteString.Lazy.Builder (toLazyByteString)
import qualified Data.Text.IO                 as T
import           Options.Applicative
import Data.Semigroup

import           Graphics.Formats.STL

data Opts = Opts String

opts :: Parser Opts
opts = Opts <$> strArgument (metavar "FILENAME" <> help "Input STL file")

copySTL :: Opts -> IO ()
copySTL (Opts fn) = do
    i <- T.readFile fn
    case parseOnly stlParser i of
        Left err -> do
            putStrLn $ "Encountered error reading "++fn
            putStrLn err
        Right stl -> do
            BS.writeFile "pretty.stl" . toLazyByteString . textSTL $ stl
            putStrLn "wrote output to pretty.stl"

main :: IO ()
main = execParser withHelp >>= copySTL where
  withHelp = info (helper <*> opts)
               ( fullDesc <> progDesc "pretty print FILENAME"
                 <> header "indent-stl - a test for STL library" )
