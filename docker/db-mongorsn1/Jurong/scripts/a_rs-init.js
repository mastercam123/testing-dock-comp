const MONGODB_HOSTNAME = _getEnv("MONGODB_HOSTNAME")

rs.initiate(
    {
      _id : 'rs1',
      members: [
        { _id : 0, host : `${MONGODB_HOSTNAME}:27017` }
      ]
    }
  )
  