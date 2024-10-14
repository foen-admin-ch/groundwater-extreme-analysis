# Function to plot return level function
display_return_level_function <- function(data, parameters, max_trend = 0, max_return_period = 100){
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
    return_levels <- compute_return_level_function(model = model, parameters = parameters, max_trend = max_trend, max_return_period = max(2  * n,max_return_period))
    
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
compute_return_level <- function(return_period, parameters, max_trend = 0, max_year = 100){
    # Determine model and estimation method
    parameters_name <- names(parameters)

    if(identical(parameters_name, c("xi","alpha","k"))){model <- "GEV_LMOM"}
    else if(identical(parameters_name, c("zeta","beta","delta"))){model <- "Weibull"}
    else if(identical(parameters_name, c("mu","sigma","gamma"))){model <- "P3"}
    else if(identical(parameters_name, c("loc","scale","shape"))){model <- "GEV_MLE"}
    else {
    stop("Invalid model's parameters.")
    }
    print(model)
    
    
    # Compute return level
    #return_level <- qweibull(p = 1 - 1 / (return_period / block_size), scale = wei[2], shape = wei[3]) + as.numeric(wei[1]) + max_trend
    if(model == "GEV_LMOM"){
    return_level <-  lmom::quagev(1 - 1 / (return_period / block_size), para = parameters) + max_trend
        }
    if(model == "Weibull"){
    return_level <-  qweibull(p = 1 - 1 / (return_period / block_size), scale = parameters[2], shape = parameters[3]) + parameters[1] + max_trend
        }
    if(model == "P3"){
    return_level <-  lmom::quape3(1 - 1 / (return_period / block_size), para = parameters) + max_trend
        }
    if(model == "GEV_MLE"){
    return_level <- evd::qgev(p = 1 - 1 / (return_period / block_size), shape = parameters["shape"], loc = parameters["loc"], scale = parameters["scale"]) + max_trend
        }
    
        
        
    # Compute retrun level function to obtain uncertainty quantification through function interporlation
    return_level_function <- compute_return_level_function(model = model, parameters = parameters, max_trend = max_trend, max_return_period = 2 * return_period)
    
    # Find closest point on curve
    pos1 <- which(rank(abs((return_level_function$model_uncertainty)$year - return_period)) == 1)
    # Find second closest point on curve
    pos2 <- which(rank(abs((return_level_function$model_uncertainty)$year - return_period)) == 2)
    # Compute linear weights for interpollation
    weights <- c(1 / abs(return_level_function$model_uncertainty$year - 10)[c(pos1,pos2)]) / sum(1 / abs(return_level_function$model_uncertainty$year - 10)[c(pos1,pos2)]) 
   
    # Compute interpolated confidence bounds
    uncertainty_interval <- c(sum(return_level_function$model_uncertainty[c(pos1,pos2),1] * weights), sum(return_level_function$model_uncertainty[c(pos1,pos2),2] * weights))
    
    #Return result as dataframe
    return(data.frame(Return_period = return_period,
                     Return_level = return_level,
                     Lower_CI_bound = uncertainty_interval[1],
                     Upper_CI_bound = uncertainty_interval[2]))
}


# Function to compute the return level function and associated uncertainty
compute_return_level_function <- function(model, parameters, max_trend = 0, max_return_period = 99){
    #Compute return level as function of the model and the estimated parameters
    return_period_estimates <- data.frame(year = c(seq(1.01,1.9, by = 0.01) , 2:9, 1:9 * 10, max(100,max_return_period)) * block_size) 
    
    if(model == "GEV_LMOM"){
    return_period_estimates$return_levels <-  lmom::quagev(1 - 1 / (return_period_estimates$year / block_size), para = parameters) + max_trend
        }
    if(model == "Weibull"){
    return_period_estimates$return_levels <-  qweibull(p = 1 - 1 / (return_period_estimates$year / block_size), scale = parameters[2], shape = parameters[3]) + parameters[1] + max_trend
        }
    if(model == "P3"){
    return_period_estimates$return_levels <-  lmom::quape3(1 - 1 / (return_period_estimates$year / block_size), para = parameters) + max_trend
        }
    if(model == "GEV_MLE"){
    return_period_estimates$return_levels <- evd::qgev(p = 1 - 1 / (return_period_estimates$year / block_size), shape = parameters["shape"], loc = parameters["loc"], scale = parameters["scale"]) + max_trend
        }
    
    # Size of bootstrap samples
    n <- max(100, max_return_period)
    pobs <- (1:n)/(n + 1)
    # Number of bootstrap samples
    m <- 10000
    
    #Generate m samples of size n
    if(model == "GEV_LMOM"){
    uncertainty_param_bootstrap <- matrix(lmom::quagev(runif(m*n), parameters), m,n)
    }
    if(model == "Weibull"){
    uncertainty_param_bootstrap <- matrix(qweibull(p = runif(n*m), scale = parameters[2], shape = parameters[3]) + parameters[1], m,n)
    }
    if(model == "P3"){
    uncertainty_param_bootstrap <- matrix(lmom::quape3(runif(m*n), parameters), m,n)
    }
    if(model == "GEV_MLE"){
    uncertainty_param_bootstrap <- matrix(evd::qgev(p = runif(m*n), shape = parameters["shape"], loc = parameters["loc"], scale = parameters["scale"]), m,n)
    }
    
    
    # Sort samples for quantile computation
    for(i in 1:nrow(uncertainty_param_bootstrap)){
        uncertainty_param_bootstrap[i,] <- sort(uncertainty_param_bootstrap[i,])
    }

    #Store bottstrap confidence intervals into dataframe
    model_uncertainty <- data.frame(lower = apply(uncertainty_param_bootstrap, 2, quantile, p = 0.005),
                              upper = apply(uncertainty_param_bootstrap, 2, quantile, p = 0.995)) + max_trend
    model_uncertainty$year <- (1 / (1 - pobs)) * block_size
    
    return(list(return_period_estimates = return_period_estimates,
               model_uncertainty = model_uncertainty))
}