{-
Monads More
-}

{-
# Writer
Writer monad is for values that have another value attached that acts as a sort of log value.
-}

-- without Writer, we need to do
applyLog :: (Monoid m) => (a,m) -> (a -> (b,m)) -> (b,m)
applyLog (x,log) f = let (y,newLog) = f x in (y,log `mappend` newLog)

-- with Writer
newtype Writer w a = Writer { runWriter :: (a, w) }  -- why w a reversed?

instance (Monoid w) => Monad (Writer w) where
    return x = Writer (x, mempty)
    (Writer (x,v)) >>= f = let (Writer (y, v')) = f x in Writer (y, v `mappend` v')


-- do notation with Writer
import Control.Monad.Writer

logNumber :: Int -> Writer [String] Int
logNumber x = Writer (x, ["Got number: " ++ show x])

multWithLog :: Writer [String] Int
multWithLog = do
    a <- logNumber 3
    b <- logNumber 5
    return (a*b)

{-
Creates a Writer value that presents the dummy value() as its result but has a desired monoid value attached.
-}
multWithLog' :: Writer [String] Int
multWithLog' = do
    a <- logNumber 3
    b <- logNumber 5
    tell ["Gonna multiply these two"]  -- desired monoid
    return (a*b)


-- Adding logging to programs
gcd' :: Int -> Int -> Writer [String] Int
gcd' a b
    | b == 0 = do
        tell ["Finished with " ++ show a]
        return a
    | otherwise = do
        tell [show a ++ " mod " ++ show b ++ " = " ++ show (a `mod` b)]
        gcd' b (a `mod` b)


{-
Difference list

In the previous section, list appending takes much time and space.

To solve, use functions chaining for list efficient appending: \xs -> [1,2,3] ++ xs
f `append` g = \xs -> f (g xs)
-}
newtype DiffList a = DiffList { getDiffList :: [a] -> [a] }

toDiffList :: [a] -> DiffList a
toDiffList xs = DiffList (xs++)

fromDiffList :: DiffList a -> [a]
fromDiffList (DiffList f) = f []

instance Monoid (DiffList a) where
    mempty = DiffList (\xs -> [] ++ xs)
    (DiffList f) `mappend` (DiffList g) = DiffList (\xs -> f (g xs))


{-
# Functions as monad
Functions are: Functor, Applicative Functor, Monad.

a function can also be considered a value with a context.  The context for functions is that that value 
is not present yet and that we have to apply that function to something in order to get its result value.

In Control.Monad.Instances 
-}

instance Monad ((->) r) where
    return x = \_ -> x
    h >>= f = \w -> f (h w) w


addStuff :: Int -> Int
addStuff = do
    a <- (*2)
    b <- (+10)
    return (a+b)

-- the function monad is also called the reader monad. All the functions read from a common source.
addStuff' :: Int -> Int
addStuff' x = let
    a = (*2) x
    b = (+10) x
    in a+b



{-
# State
-}