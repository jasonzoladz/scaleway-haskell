{-# LANGUAGE DataKinds                  #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE TypeOperators              #-}

module Scaleway.API.Core
    ( XAuthToken (..)
    , ScalewayAuthToken
    , ScalewayClient
    , PerPage
    , Page
    , scalewayGetListRequest
    , scalewayGetSingleRequest
    , scalewayPostRequest
    , scalewayPutRequest
    , scalewayDeleteRequest
    , runClient
    ) where

import           Control.Monad.Reader    (ReaderT, ask, runReaderT)
import           Control.Monad.Trans     (lift)
import           Data.Aeson              (FromJSON, ToJSON)
import           Data.String             (IsString)
import           Data.Text               (Text)
import           Network.HTTP.Client.TLS (newTlsManager)
import           Scaleway.Types          (Region)
import           Servant.API             ((:>), Header, QueryParam,
                                          ToHttpApiData (toUrlPiece))
import           Servant.Client          (BaseUrl (..), ClientEnv (..), ClientM,
                                          Scheme (..), ServantError, runClientM)

newtype XAuthToken = XAuthToken Text
  deriving (Eq, Show, IsString, ToHttpApiData)

newtype PerPage = PerPage Int
  deriving (Eq, Show, Num, ToHttpApiData)

newtype Page = Page Int
  deriving (Eq, Show, Num, ToHttpApiData)

type ScalewayAuthToken = Header "X-Auth-Token" XAuthToken


type ScalewayClient a = ReaderT XAuthToken ClientM a

clientEnv :: Region -> IO ClientEnv
clientEnv region = do
  let host = "cp-" ++ show region ++ ".scaleway.com"
  manager <- newTlsManager
  pure $ ClientEnv manager (BaseUrl Http host 80 "")

runClient :: ScalewayClient a -> Region -> XAuthToken -> IO (Either ServantError a)
runClient c r token = do
  env <- clientEnv r
  runClientM (runReaderT c token) env

scalewayGetListRequest :: FromJSON a
                       => (Maybe XAuthToken -> Maybe PerPage -> Maybe Page -> ClientM a)
                       -> Maybe PerPage -> Maybe Page -> ScalewayClient a
scalewayGetListRequest r perPage page = do
  token <- ask
  lift $ r (Just token) perPage page

scalewayGetSingleRequest :: FromJSON a
                         => (Maybe XAuthToken -> Text -> ClientM a)
                         -> Text -> ScalewayClient a
scalewayGetSingleRequest r resourceId = do
  token <- ask
  lift $ r (Just token) resourceId

scalewayPostRequest :: (ToJSON a, FromJSON b)
                    => (Maybe XAuthToken -> a -> ClientM b)
                    -> a -> ScalewayClient b
scalewayPostRequest r postData = do
  token <- ask
  lift $ r (Just token) postData

scalewayPutRequest :: (ToJSON a, FromJSON b)
                   => (Maybe XAuthToken -> Text -> a -> ClientM b)
                   -> Text -> a -> ScalewayClient b
scalewayPutRequest r resourceId body = do
  token <- ask
  lift $ r (Just token) resourceId body

scalewayDeleteRequest :: (Maybe XAuthToken -> Text -> ClientM ())
                      -> Text -> ScalewayClient ()
scalewayDeleteRequest r resourceId = do
  token <- ask
  lift $ r (Just token) resourceId