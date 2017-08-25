{-# LANGUAGE DataKinds                  #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE OverloadedStrings          #-}
{-# LANGUAGE TypeOperators              #-}

module Scaleway.API
    ( module API
    , ScalewayAPI
    , Page (..)
    , PerPage (..)
    , XAuthToken (..)
    , runClient
    )where

import           Data.Proxy                 (Proxy (..))
import           Scaleway.API.Core          (Page, PerPage, XAuthToken,
                                             runClient)
import           Scaleway.API.Image         as API
import           Scaleway.API.Ip            as API
import           Scaleway.API.Organization  as API
import           Scaleway.API.SecurityGroup as API
import           Scaleway.API.Server        as API
import           Scaleway.API.Snapshot      as API
import           Scaleway.API.Token         as API
import           Scaleway.API.Volume        as API
import           Scaleway.Types             as API
import           Servant.API                ((:<|>) (..))

type ScalewayAPI =
       ServerAPI
  :<|> ImageAPI
  :<|> VolumeAPI
  :<|> IpAPI
  :<|> SnapshotAPI
  :<|> SecurityGroupAPI
  :<|> TokenAPI
  :<|> OrganizationAPI

scalewayAPI :: Proxy ScalewayAPI
scalewayAPI = Proxy