#Tell all slaves to return a message identifying themselves.
library("Rmpi")
sprintf("TEST mpi.universe.size() =  %i", mpi.universe.size())
ns <- mpi.universe.size() - 1
sprintf("TEST attempt to spawn %i slaves", ns)
mpi.spawn.Rslaves(nslaves=ns)
mpi.remote.exec(paste("I am",mpi.comm.rank(),"of",mpi.comm.size()))
mpi.remote.exec(paste(mpi.comm.get.parent()))
#Send execution commands to the slaves
x<-5
#These would all be pretty correlated one would think
x<-mpi.remote.exec(rnorm,x)
length(x)
x
mpi.close.Rslaves()
mpi.quit()
