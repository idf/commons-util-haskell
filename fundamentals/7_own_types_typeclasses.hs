import Data.List
import qualified Data.Map as Map
{-
# Own types and typeclasses
-}

{-
# Algebraic data types
-}

-- | Value constructors are actually functions that ultimately return a value of a data type.
-- Shape is a type, Circle isn't.
data Shape1 = Circle1 Float Float Float | Rectangle1 Float Float Float Float
           deriving (Show) -- show

-- | Pattern matching for constructors
surface1 :: Shape1 -> Float
surface1 (Circle1 _ _ r) = pi * r ^ 2
surface1 (Rectangle1 x1 y1 x2 y2) = (abs $ x2 - x1) * (abs $ y2 - y1)

-- | Currying for value constructors
circles1 = map (Circle1 10 20) [4,5,6,6]

-- | used the same name for the data type and the value constructor, if only one constructor
data Point = Point Float Float deriving (Show)
data Shape = Circle Point Float | Rectangle Point Point deriving (Show)

-- | nested pattern matching
surface :: Shape -> Float
surface (Circle _ r) = pi * r ^ 2
surface (Rectangle (Point x1 y1) (Point x2 y2)) = (abs $ x2 - x1) * (abs $ y2 - y1)

{-
To export all the value constructors for a given type, just write ..
module Shapes
( Point(..)
, Shape(..)
) where

If opt not to export any value constructors for Shape by just writing Shape in the export statement.
That way, someone importing our module could only make shapes by using the auxilliary functions.
-}

{-
# Record Syntax

creates functions that lookup fields in the data type.
-}
data Person = Person { firstName :: String
                     , lastName :: String
                     , age :: Int
                     , height :: Float
                     , phoneNumber :: String
                     , flavor :: String
                     } deriving (Show)

-- | dict constructor
data Car = Car {company :: String, model :: String, year :: Int} deriving (Show)

aCar = Car "Ford" "Mustang" 1967
aCarDict = Car {company="Ford", model="Mustang", year=1967}

showCar :: Car -> String
showCar (Car {company = c, model = m, year = y}) = "This " ++ c ++ " " ++ m ++ " was made in " ++ show y

{-
# Type parameters
## Type constructor
Value constructor -> type constructor
data <Type> <param> = ... e.g. "a" as the type parameter. Similar to Java
generics
* Maybe a
* [a]

A list of stuff is a list of stuff and it doesn't matter what the type of that
stuff is, it can still work.

Polymorphic type: Nothing is polymorphic type

## Typeclass constraints in data
Strong convention in Haskell to never add typeclass constraints in data
declarations, since have to put them into the function type declarations
either way.
-}

-- | Implementation of "Maybe"
-- a is a type parameter, thus Maybe' generates a type, e.g. Maybe Int
-- No value can have a type of Maybe, because that's not a type per se, it's a type constructor.
data Maybe' a = Nothing' | Just' a
-- | Just Int, the Int type is inferred
aMaybe = Just 0

-- | Car String String int, although no practical usage.
data Car' a b c = Car' { company' :: a
                       , model' :: b
                       , year' :: c
                       } deriving (Show)

aCar' = Car' "Ford" "Mustang" 1967

tellCar' :: (Show a) => Car' String String a -> String
tellCar' (Car' {company' = c, model' = m, year' = y}) = "This " ++ c ++ " " ++ m ++ " was made in " ++ show y

{-
# Derived Instance
## Typeclass
"typeclass" is like a interface, "type" implemnts the interface.
e.g. the Int type is an instance of the Eq typeclass.
deriving (<typeclass>)

Type vs. Typeclass
If treat "type" as value, "typeclass" becomes type function, takes type value and returns a new type; type constructor.

Ord
* First comes in value constructor is smaller
* If equal, nested compare

Enum
* successor, predecessor: succ, pred

Bounded
* head smallest, tail largest;
* minBound, maxBound
-}

data Person' = Person' { firstName' :: String
                       , lastName' :: String
                       , age' :: Int
                       } deriving (Eq, Show, Read)

deserializePerson = read "Person' {firstName' =\"Michael\", lastName' =\"Diamond\", age' = 43}" :: Person'

-- | nullary constructor
data Day = Monday | Tuesday | Wednesday | Thursday | Friday | Saturday | Sunday
         deriving (Eq, Ord, Show, Read, Bounded, Enum)

-- | ellipsis
partialDays = [Thursday .. Sunday]

-- | range
entireDays = [minBound .. maxBound] :: [Day]


{-
# Type synonyms

Different name binding:
type String = [Char]

Type constructors vs. Value constructors
unable to do: TypeConstructor [(1,2),(4,5),(7,9)]
able to do: [(1,2),(3,5),(8,9)] :: TypeConstructor Int Int
-}

type PhoneBook = [(String,String)]

-- | Type constructor, parameterized type synonyms
type AssocList k v = [(k,v)]

-- | Type constructor currying, since type constructor is a func
type IntMap v = Map.Map Int v
type IntMap' = Map.Map Int

-- | Implementation of "Either", value constructor
-- errors use the Left value constructor while results use Right
data Either' a b = Left' a | Right' b deriving (Eq, Ord, Read, Show)


-- | locker example
data LockerState = Taken | Free deriving (Show, Eq) -- not Enum, but like enumerate
type Code = String
type LockerMap = Map.Map Int (LockerState, Code)

lockerLookup :: Int -> LockerMap -> Either String Code  -- returns Either
lockerLookup lockerNumber map =
    case Map.lookup lockerNumber map of  -- Map.lookup returns Maybe
         Nothing -> Left $ "Locker number " ++ show lockerNumber ++ " doesn't exist!"
         Just (state, code) -> if state /= Taken then
                                   Right code
                               else
                                   Left $ "Locker " ++ show lockerNumber ++ " is already taken!"

lockers :: LockerMap
lockers = Map.fromList
    [(100,(Taken,"ZD39I"))
    ,(101,(Free,"JAH3I"))
    ,(103,(Free,"IQSA9"))
    ,(105,(Free,"QOTSA"))
    ,(109,(Taken,"893JJ"))
    ,(110,(Taken,"99292"))
    ]

{-
# Recursive Data Structures
-}
-- | Infix
-- infixr <fixity> <special_chars>; fixitity is the precedence level

-- | Implementation of "++"
infixr 5  .++
(.++) :: List a -> List a -> List a
Empty .++ ys = ys
(x :-: xs) .++ ys = x :-: (xs .++ ys)

-- | List, an implementation of "[a]"
data List' a = Empty' | Cons a (List' a) deriving (Show, Read, Eq, Ord)
-- Cons is another word for "(:)"
infixr 5 :-:
data List a = Empty | a :-: (List a) deriving (Show, Read, Eq, Ord)

-- | Tree
data Tree a = EmptyTree | Node a (Tree a) (Tree a) deriving (Show, Read, Eq)

-- | construct tree
singleton :: a -> Tree a
singleton x = Node x EmptyTree EmptyTree

treeInsert :: (Ord a) => a -> Tree a -> Tree a
treeInsert x EmptyTree = singleton x
treeInsert x (Node a left right)
    | x == a = Node x left right
    | x < a  = Node a (treeInsert x left) right
    | x > a  = Node a left (treeInsert x right)

treeFromList xs = foldr treeInsert EmptyTree xs

-- | search tree
treeElem :: (Ord a) => a -> Tree a -> Bool
treeElem x EmptyTree = False
treeElem x (Node a left right)
    | x == a = True
    | x < a  = treeElem x left
    | x > a  = treeElem x right


{-
# Own typeclasses
* typeclasses are like interfaces
* typeclass is not related class in OOP languages
* types that can behave in that way are made instances of that typeclass
* behavior of typeclasses is achieved by defining functions or just type declarations

## constraints
* class constraints in class declarations are used for making a typeclass a subclass of another typeclass.
* class constraints in instance declarations are used to express require- ments about the contents of some type
-}

-- | implementation of "Eq" typeclass
-- rename funcs, otherwise Ambiguous occurrence ‘==’
class Eq' a where  -- a type variable, equiv equitable
    (.==) :: a -> a -> Bool -- type declarations
    (./=) :: a -> a -> Bool
    x .== y = not (x ./= y)  -- mutual recursion, thus only need to define == later in instance
    x ./= y = not (x .== y)

-- | types instances of typeclasses
data TrafficLight = Red | Yellow | Green


-- | instanc of class
-- minimal complete definition: ==
instance Eq TrafficLight where
    Red == Red       = True
    Green == Green   = True
    Yellow == Yellow = True
    _ == _           = False  -- default, catch-all pattern


-- | deriving (show) by hand
instance Show TrafficLight where
    show Red = "Red light"
    show Yellow = "Yellow light"
    show Green = "Green light"


-- | subclasses typeclasses --> class constraints
-- class (Eq a) => Num a where ...


-- | type constructor as instance of typeclass
-- unable to write "instance Eq Maybe where" since Maybe is not a type
instance (Eq m) => Eq (Maybe' m) where
    Just' x == Just' y   = x == y  -- (Eq m) typeclass constraint
    Nothing' == Nothing' = True
    _ == _               = False


{-
yes-no typeclass
-}