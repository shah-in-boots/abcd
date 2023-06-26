library(clustermq)
fx = function(x) x * 2
Q(fx, x = 1:3, n_jobs = 1, log_worker = TRUE)

