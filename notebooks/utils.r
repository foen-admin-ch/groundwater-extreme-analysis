# Function to plot return level function
display_return_level_function <- function(data, parameters, max_trend = 0, max_return_period = 100, m = 1000){
    # Determine model and estimation method
    parameters_name <- names(parameters)

    if(identical(parameters_name, c("xi","alpha","k"))){model <- "GEV_LMOM"}
    else if(identical(parameters_name, c("zeta","beta","delta"))){model <- "Weibull"}
    else if(identical(parameters_name, c("mu","sigma","gamma"))){model <- "P3"}
    else if(identical(parameters_name, c("loc","scale","shape"))){model <- "GEV_MLE"}
    else {
    stop("Invalid model's parameters.")
    }
    
    #Sort maxima data for visual checks
    n <- length(data$Max_standardized)
    data_maxima_sorted <-  data
    data_maxima_sorted$Max <- sort(data$Max_standardized) + max_trend
    data_maxima_sorted$year <- 1 / (1 - 1:n / (n + 1)) * block_size
    
    # Compute retrun level function
    return_levels <- compute_return_level_function(model = model, parameters = parameters, n_obs = n, max_trend = max_trend, max_return_period = max(2  * n,max_return_period), m = m)
    
    # Create return level function plot
    p <- ggplot() +
        geom_line(data = return_levels$return_period_estimates, aes(x = year, y = return_levels)) + 
        geom_line(data = return_levels$model_uncertainty, aes(x = year, y = lower), linetype = "dotted", color = "black") +  
        geom_line(data = return_levels$model_uncertainty, aes(x = year, y = upper), linetype = "dotted", color = "black") + 
        geom_point(data = data_maxima_sorted, aes(x = year, y = Max)) +
        scale_x_continuous(trans='log2', breaks = c(1,2,5,10,20, 50 ,100)) +
        geom_vline(xintercept = 10 , color = "red") + theme_classic() + theme(text = element_text(size = 20))+
        xlab("Return Period") + ylab("Return Level")
    
    print(p)
}

# Function to povide a return level and associated uncertainy for a given return period
compute_return_level <- function(return_period, parameters, n_obs, max_trend = 0, m = 1000){
    # Determine model and estimation method
    parameters_name <- names(parameters)

    if(identical(parameters_name, c("xi","alpha","k"))){model <- "GEV_LMOM"}
    else if(identical(parameters_name, c("zeta","beta","delta"))){model <- "Weibull"}
    else if(identical(parameters_name, c("mu","sigma","gamma"))){model <- "P3"}
    else if(identical(parameters_name, c("loc","scale","shape"))){model <- "GEV_MLE"}
    else {
    stop("Invalid model's parameters.")
    }    
    
    # Compute return level from estimates
    if(model == "GEV_LMOM"){
    return_level <-  lmom::quagev(1 - 1 / (return_period / block_size), para = parameters) + max_trend
        }
    if(model == "Weibull"){
    return_level <-  qweibull(p = 1 - 1 / (return_period / block_size), scale = parameters[2], shape = parameters[3]) + unname(parameters[1]) + max_trend
        }
    if(model == "P3"){
    return_level <-  lmom::quape3(1 - 1 / (return_period / block_size), para = parameters) + max_trend
        }
    if(model == "GEV_MLE"){
    return_level <- evd::qgev(p = 1 - 1 / (return_period / block_size), shape = parameters["shape"], loc = parameters["loc"], scale = parameters["scale"]) + max_trend
        }
    
    # Bootstrap matrix
    uncertainty_param_bootstrap <- rep(NA,m)
                                          
    #Generate m samples of size n
    if(model == "GEV_LMOM"){
            for(i in 1:m){
            lmom <- samlmu(lmom::quagev(runif(n_obs), parameters))
            gev <- pelgev(lmom)
            uncertainty_param_bootstrap[i] <- lmom::quagev(1 - 1 / (return_period / block_size), para = gev) + max_trend
            }
    }
    if(model == "Weibull"){
        for(i in 1:m){
        lmom <- samlmu(qweibull(p = runif(n_obs), scale = parameters[2], shape = parameters[3]) + parameters[1])
            try(expr = {wei <- pelwei(lmom)
        uncertainty_param_bootstrap[i] <- qweibull(p = 1 - 1 / (return_period / block_size), scale = wei[2], shape = wei[3]) + unname(wei[1]) + max_trend}, silent = TRUE)
            }
    }
    if(model == "P3"){
        for(i in 1:m){
            lmom <- samlmu(lmom::quape3(runif(n_obs), parameters))
            p3 <- pelpe3(lmom)
            uncertainty_param_bootstrap[i] <- lmom::quape3(1 - 1 / (return_period / block_size), para = p3) + max_trend
            }
    }
    if(model == "GEV_MLE"){
        for(i in 1:m){
            gev_fit <- evd::fgev(evd::qgev(p = runif(n_obs), shape = parameters["shape"], loc = parameters["loc"], scale = parameters["scale"]), std.err = FALSE)
           uncertainty_param_bootstrap[i] <- evd::qgev(p = 1 - 1 / (return_period / block_size), shape = gev_fit$param["shape"], loc = gev_fit$param["loc"], scale = gev_fit$param["scale"])  + max_trend
            }
    }
    
    #Return result as dataframe
    return(data.frame(Return_period = return_period,
                     Return_level = return_level,
                     Lower_99_CI_bound = quantile(uncertainty_param_bootstrap, p = 0.005, na.rm = TRUE),
                     Upper_99_CI_bound = quantile(uncertainty_param_bootstrap, p = 0.995, na.rm = TRUE),
          row.names=NULL))
}


# Function to compute the return level function and associated uncertainty
compute_return_level_function <- function(model, parameters, n_obs, max_trend = 0, max_return_period = 99, m = 1000){
    #Compute return level as function of the model and the estimated parameters
    return_period_estimates <- data.frame(year = c(seq(1.01,1.9, by = 0.01) , 2:9, 1:9 * 10, max(100,max_return_period)) * block_size) 
    
    if(model == "GEV_LMOM"){
    return_period_estimates$return_levels <-  lmom::quagev(1 - 1 / (return_period_estimates$year / block_size), para = parameters) + max_trend
        }
    if(model == "Weibull"){
    return_period_estimates$return_levels <-  qweibull(p = 1 - 1 / (return_period_estimates$year / block_size), scale = parameters[2], shape = parameters[3]) + unname(parameters[1]) + max_trend
        }
    if(model == "P3"){
    return_period_estimates$return_levels <-  lmom::quape3(1 - 1 / (return_period_estimates$year / block_size), para = parameters) + max_trend
        }
    if(model == "GEV_MLE"){
    return_period_estimates$return_levels <- evd::qgev(p = 1 - 1 / (return_period_estimates$year / block_size), shape = parameters["shape"], loc = parameters["loc"], scale = parameters["scale"]) + max_trend
        }
    
    # Bootstrap matrix
    uncertainty_param_bootstrap <- matrix(NA,m,length(return_period_estimates$year))
                                          
    #Generate m samples of size n
    if(model == "GEV_LMOM"){
            for(i in 1:m){
            lmom <- samlmu(lmom::quagev(runif(n_obs), parameters))
            gev <- pelgev(lmom)
            uncertainty_param_bootstrap[i,] <- lmom::quagev(1 - 1 / (return_period_estimates$year / block_size), para = gev) + max_trend
            }
    }
    if(model == "Weibull"){
        for(i in 1:m){
        lmom <- samlmu(qweibull(p = runif(n_obs), scale = parameters[2], shape = parameters[3]) + parameters[1])
            try(expr = {wei <- pelwei(lmom)
        uncertainty_param_bootstrap[i,] <- qweibull(p = 1 - 1 / (return_period_estimates$year / block_size), scale = wei[2], shape = wei[3]) + unname(wei[1]) + max_trend}, silent = TRUE)
            }
    }
    if(model == "P3"){
        for(i in 1:m){
            lmom <- samlmu(lmom::quape3(runif(n_obs), parameters))
            p3 <- pelpe3(lmom)
            uncertainty_param_bootstrap[i,] <- lmom::quape3(1 - 1 / (return_period_estimates$year / block_size), para = p3) + max_trend
            }
    }
    if(model == "GEV_MLE"){
        for(i in 1:m){
            gev_fit <- evd::fgev(evd::qgev(p = runif(n_obs), shape = parameters["shape"], loc = parameters["loc"], scale = parameters["scale"]), std.err = FALSE)
           uncertainty_param_bootstrap[i,] <- evd::qgev(p = 1 - 1 / (return_period_estimates$year / block_size), shape = gev_fit$param["shape"], loc = gev_fit$param["loc"], scale = gev_fit$param["scale"])
            }
    }

    #Store bootstrap confidence intervals into dataframe
    model_uncertainty <- data.frame(lower = apply(uncertainty_param_bootstrap, 2, quantile, p = 0.005, na.rm = TRUE),
                              upper = apply(uncertainty_param_bootstrap, 2, quantile, p = 0.995,  na.rm = TRUE))
    model_uncertainty$year <- return_period_estimates$year
    
    return(list(return_period_estimates = return_period_estimates,
               model_uncertainty = model_uncertainty))
}