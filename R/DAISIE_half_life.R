#function to detect the time taken for the relaxation half life
#uses the object output from DAISIE_sim_core


#' Title
#'
#' @param time 
#' @param mainland_n 
#' @param pars 
#' @param nonoceanic 
#' @authorJosh Lambert 
#'
#' @return
#' @export
#'
#' @examples
DAISIE_sim_half_life <- function(time,mainland_n,pars,nonoceanic)
{
  #run simulation
  sim <- DAISIE_sim_core(time,mainland_n,pars,nonoceanic)
  
  #initial number of species
  N0 <- sum(sim$stt_table[1,2:4])
  
  #half-life of time taken to reach half way between initial species diversity and K
  t_half <- N0 - ((N0 - pars[3])/2)
  t_half <- round(t_half, digits = 0)
  
  #which row is the half-life number of species on
  test <- sim$stt_table[,2:4]
  row <- apply(X = test, MARGIN = 1, FUN = sum)
  row <- which(row == t_half)
  if (length(row) > 1)
  {
    row <- row[1]
  }
  
  #what is the time when the half-life is reached
  sim$stt_table[row,1]
  
  #the time take to reach the half-life
  half_life <- time - (sim$stt_table[row,1])
  
  return(half_life)
}

  
  
#' Title
#'
#' @param sim 
#'
#' @return
#' @export
#'
#' @examples
DAISIE_half_life <- function(sim)
{
  
  #initial number of species
  N0 <- sum(sim$stt_table[1,2:4])
  
  #half-life of time taken to reach half way between initial species diversity and K
  t_half <- N0 - ((N0 - pars[3])/2)
  t_half <- round(t_half, digits = 0)
  
  #which row is the half-life number of species on
  test <- sim$stt_table[,2:4]
  row <- apply(X = test, MARGIN = 1, FUN = sum)
  row <- which(row == t_half)
  if (length(row) > 1)
  {
    row <- row[1]
  }
  
  #what is the time when the half-life is reached
  sim$stt_table[row,1]
  
  #the time take to reach the half-life
  half_life <- time - (sim$stt_table[row,1])
  
  return(half_life)
}
 

#' Title
#'
#' @param time 
#' @param M 
#' @param pars 
#' @param replicates 
#' @param nonoceanic 
#' @param divdepmodel 
#' @param prop_type2_pool 
#' @param replicates_apply_type2 
#' @param sample_freq 
#' @param plot_sims 
#'
#' @return
#' @export
#'
#' @examples
DAISIE_sim_avg_half_life <- function (time,M,pars,replicates,nonoceanic,divdepmodel = 'CS',
                                      prop_type2_pool = NA,replicates_apply_type2 = TRUE,
                                      sample_freq = 10000,plot_sims = TRUE)
{
  sim_reps <- DAISIE_sim(time,M,pars,replicates,nonoceanic,divdepmodel,prop_type2_pool,
                         replicates_apply_type2,sample_freq,plot_sims)
  
  #initial number of species for each simulation
  N0 <- matrix(nrow = length(sim_reps), ncol = 1)
  for (i in 1:length(sim_reps))
  {
    N0[i,1] <- sum(sim_reps[[i]][[1]]$stt_all[1,2:4])
  }
  
  #Half way between initial species diversity and K
  spec_half <- matrix(nrow = length(sim_reps), ncol = 1)
  for (i in 1:length(N0))
  {
    spec_half[i,1] <- N0[i] - ((N0[i] - pars[3])/2)
  }
  
  #get total number of species through time
  spec_through_time_tables <- list()
  for (i in 1:length(sim_reps))
  {
    spec_through_time_tables[[i]] <- sim_reps[[i]][[1]]$stt_all[,2:4]
  }
  
  sum_spec_through_time <- matrix(ncol = length(sim_reps),nrow = nrow(spec_through_time_tables[[1]]))
  for (i in 1:length(sim_reps))
  {
    sum_spec_through_time[,i] <- apply(X = spec_through_time_tables[[i]], MARGIN = 1, FUN = sum)
  } 
  
  total_spec <- matrix(ncol = 1, nrow = nrow(spec_through_time_tables[[1]]))
  total_spec[,1] <- sim_reps[[1]][[1]]$stt_all[,1]
  total_spec <- cbind(total_spec,sum_spec_through_time) 
  
  #plot a spline for species diversity through time for each rep
  time_seq <- seq(0,max(total_spec[,1]),0.001)
  splines <- list()
  half_life_predict <- list()
  for (i in 2:ncol(total_spec))
  {
    splines[[i]] <- smooth.spline(x = total_spec[,1],y = total_spec[,i],df=1000)
    half_life_predict[[i]] <- predict(splines[[i]], time_seq)
    half_life_predict[[i]] <- cbind(half_life_predict[[i]]$x,half_life_predict[[i]]$y)
  }
  
  half_time <- matrix(ncol=1,nrow=length(sim_reps))
  for (i in 1:ncol(sum_spec_through_time))
  {
    half_time[[i]] <- which.min(abs(sum_spec_through_time[,i] - spec_half[i,1]))
    half_time[[i]] <- total_spec[half_time[i],1]
  }  
  
  #the time take to reach the half-life
  half_life <- matrix(nrow = length(sim_reps), ncol = 1)
  for (i in 1:length(sim_reps))
  {
    half_life[i,1] <- max(total_spec[,1]) - (half_time[i])
  }
  
  return(half_life)
}


#' Title
#'
#' @param sim_reps 
#'
#' @return
#' @export
#'
#' @examples
DAISIE_avg_half_life <- function (sim_reps)
{
  #initial number of species for each simulation
  N0 <- matrix(nrow = length(sim_reps), ncol = 1)
  for (i in 1:length(sim_reps))
  {
    N0[i,1] <- sum(sim_reps[[i]][[1]]$stt_all[1,2:4])
  }
  
  #Half way between initial species diversity and K
  spec_half <- matrix(nrow = length(sim_reps), ncol = 1)
  for (i in 1:length(N0))
  {
    spec_half[i,1] <- N0[i] - ((N0[i] - pars[3])/2)
  }
  
  #get total number of species through time
  spec_through_time_tables <- list()
  for (i in 1:length(sim_reps))
  {
    spec_through_time_tables[[i]] <- sim_reps[[i]][[1]]$stt_all[,2:4]
  }
  
  sum_spec_through_time <- matrix(ncol = length(sim_reps),nrow = nrow(spec_through_time_tables[[1]]))
  for (i in 1:length(sim_reps))
  {
    sum_spec_through_time[,i] <- apply(X = spec_through_time_tables[[i]], MARGIN = 1, FUN = sum)
  } 
  
  total_spec <- matrix(ncol = 1, nrow = nrow(spec_through_time_tables[[1]]))
  total_spec[,1] <- sim_reps[[1]][[1]]$stt_all[,1]
  total_spec <- cbind(total_spec,sum_spec_through_time) 
  
  #plot a spline for species diversity through time for each rep
  time_seq <- seq(0,max(total_spec[,1]),0.001)
  splines <- list()
  half_life_predict <- list()
  for (i in 2:ncol(total_spec))
  {
    splines[[i]] <- smooth.spline(x = total_spec[,1],y = total_spec[,i],df=10)
    half_life_predict[[i]] <- predict(splines[[i]], time_seq)
    half_life_predict[[i]] <- cbind(half_life_predict[[i]]$x,half_life_predict[[i]]$y)
  }
  
  half_time <- matrix(ncol=1,nrow=length(sim_reps))
  for (i in 1:ncol(sum_spec_through_time))
  {
    half_time[[i]] <- which.min(abs(sum_spec_through_time[,i] - spec_half[i,1]))
    half_time[[i]] <- total_spec[half_time[i],1]
  }  
  
  #the time take to reach the half-life
  half_life <- matrix(nrow = length(sim_reps), ncol = 1)
  for (i in 1:length(sim_reps))
  {
    half_life[i,1] <- max(total_spec[,1]) - (half_time[i])
  }
  
  return(half_life)
}

