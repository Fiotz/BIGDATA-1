```haskell
-- |professions
data Ocupacao = Engenheiro | Professor | Gerente | Estudante
              deriving (Show, Read, Enum)

-- |letter grade
data Conceito = F | D | C | B | A
              deriving (Show, Read, Enum)

-- |'rank' converts the Conceito into a normalized rank value
rank :: String -> Double
rank co = (fromEnum' co') / (fromEnum' A)
  where 
    co' = read co :: Conceito
    fromEnum' = fromIntegral . fromEnum

-- |'binarize' parses a Ocupacao into a binary list
binarize :: String -> [Double]
binarize oc = [bool2double $ oc' ==  i | i <- [0..3]]
  where
    oc' = fromEnum (read oc :: Ocupacao)
    bool2double True  = 1.0
    bool2double False = 0.0

-- |'parseFile' parses a space separated file 
-- to a list of lists of Double
parseFile :: String -> [[Double]]
parseFile file = map parseLine (lines file)
  where
    parseLine l = concat $ toDouble (words l)
    toDouble [oc, co, grade] = [binarize oc, [rank co, read grade]]
```

```haskell
-- |'minkowski' distance
minkowski :: Double -> [Double] -> [Double] -> Double
minkowski p x y  = summation ** (1.0/p)
  where
    summation = sum $ zipWith (pointwiseDist) x y
    pointwiseDist xi yi = (abs (xi - yi)) ** p

-- |'euclidean' is just a special case of minkowski
euclidean :: [Double] -> [Double] -> Double
euclidean = minkowski 2

-- |'jaccard' distance
jaccard :: [Double] -> [Double] -> Double
jaccard x y = 1 - (sumProd / sumSum)
  where
    sumProd = sum $ zipWith (*) x y
    sumSum  = sum $ zipWith (binsum) x y

-- |'binsum' is a binary addition for Jaccard
binsum :: Double -> Double -> Double
binsum 1 _ = 1
binsum _ 1 = 1
binsum _ _ = 0

cosine :: [Double] -> [Double] -> Double
cosine x y = (dotprod x y) / (norm' x * norm' y)
  where
    dotprod u v = sum $ zipWith (*) u v
    norm' u  = dotprod u u

-- |'standardize' a vector
standardize :: [Double] -> [Double]
standardize x = map toCenter x
  where
    toCenter xi = (xi - mean x) / stdX
    mean x = (sum x) / (length' x)
    stdX  = sqrt varX
    varX  = mean $ map (\xi -> (xi - mean x) ** 2) x
    length' l = fromIntegral $ length l

-- |'maxminScale' scales vector to [0,1]
maxminScale :: [Double] -> [Double]
maxminScale x = map scale x
  where
    scale xi = (xi - minimum x) / (maximum x - minimum x)

-- |'norm' calculates the norm vector
norm :: [Double] -> [Double]
norm x = map (/nx) x
  where
    nx = sqrt . sum $ map (^2) x
```

```haskell
type TF = M.HashMap String Integer

tokenize :: String -> [[String]]
tokenize text = filter (not . null) $ map process (lines text)
  where
    process line   = filter moreThanTwo $ map normalize (words line)
    normalize word   = filter (/=' ') $ map lowerReplace word
    lowerReplace c = if isAlphaNum c then toLower c else ' '
    moreThanTwo l = length l > 2

-- |generate 'n-grams' from tokenized text
ngrams :: [[String]] -> Int -> [[String]]
ngrams corpus n = map ngrams' corpus
  where
    ngrams' tokens = map (intercalate " ") $ grams tokens
    grams tokens = sizeN $ map (take n) $ tails tokens 
    sizeN l = filter (\l' -> length l' == n) l

-- |'binarize' the corpus of BoW
binarize :: [[String]] -> [TF]
binarize corpus = map binVec corpus
  where
    binVec line = M.fromList $ zip line [1,1..]

-- |'tf' generates the term frequency of a BoW
tf :: [[String]] -> [TF]
tf corpus = map countWords corpus
  where
    countWords doc = M.fromListWith (+) $ zip doc [1,1..]

-- | 'df' calculates document frequency of words in a dictionary
df :: [TF] -> TF
df corpus = foldl' (M.unionWith (+)) M.empty corpus
```