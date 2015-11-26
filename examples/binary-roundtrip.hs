import qualified Data.ByteString      as BS
import           Data.Serialize
import           Options.Applicative

import           Graphics.Formats.STL

data Opts = Opts String

opts :: Parser Opts
opts = Opts <$> strArgument (metavar "FILENAME" <> help "Input STL file")

copySTL :: Opts -> IO ()
copySTL (Opts fn) = do
    i <- BS.readFile fn
    case runGet (get :: Get STL) i of
        Left err -> do
            putStrLn $ "Encountered error reading "++fn
            putStrLn err
        Right stl -> do
            BS.writeFile "roundtrip.stl" . runPut . put $ stl
            putStrLn "wrote output to roundtrip.stl"

main :: IO ()
main = execParser withHelp >>= copySTL where
  withHelp = info (helper <*> opts)
               ( fullDesc <> progDesc "read  FILENAME as a binary STL, and write out \"roundtrip.stl\", also as binary STL"
                 <> header "binary-roundtrip - a test for STL library" )
