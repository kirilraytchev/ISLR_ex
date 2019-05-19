# fun library developed while going through the ex. of the ISLR book
#

## tidy fun for the best subset method
## Ch6 Linear Model Selection and Regularization
##
tidy.regsubsets <- function(x, ...) {
        s <- summary(x)
        inclusions <- as_tibble(s$which)
        metrics <- with(
                s,
                tibble(
                        r.squared = rsq,
                        adj.r.squared = adjr2,
                        BIC = bic,
                        mallows_cp = cp,
                        rss = rss
                )
        )
        bind_cols(inclusions, metrics)
}

## gen graphs for the best subset method
## Ch6 Linear Model Selection and Regularization
##
graph.bestsubset <- function(tbestsel){
        
        gg.adj.r <- ggplot(data = tbestsel, aes(y = adj.r.squared, x = model.number)) + 
                geom_point(color = "red", size = 3) +
                geom_line() +
                scale_x_discrete(limits = c(1:nrow(tbestsel))) +
                xlab("model number")
        
        gg.rss <- ggplot(data = tbestsel, aes(y = rss, x = model.number)) + 
                geom_point(color = "yellow", size = 3) +
                geom_line() +
                scale_x_discrete(limits = c(1:nrow(tbestsel))) +
                xlab("model number")
        
        gg.cp <- ggplot(data = tbestsel, aes(y = mallows_cp, x = model.number)) + 
                geom_point(color = "blue", size = 3) +
                geom_line() +
                scale_x_discrete(limits = c(1:nrow(tbestsel))) +
                xlab("model number")
        
        gg.bic <- ggplot(data = tbestsel, aes(y = BIC, x = model.number)) + 
                geom_point(color = "green", size = 3) +
                geom_line() +
                scale_x_discrete(limits = c(1:nrow(tbestsel))) +
                xlab("model number")

        grid.arrange(gg.adj.r, gg.rss, gg.cp, gg.bic, ncol = 2)
}

## mse(s) of the best subset method
## Ch6 Linear Model Selection and Regularization
##
mse.bestsubset <- function(tbestsel, mod_fit, mod_form, data_in, data_pred){
        
        predict.regsubsets = function(id, object, formula, newdata, ...){
                form = as.formula(formula)
                mat = model.matrix(form, newdata)
                coefi = coef(object, id=id)
                xvars = names(coefi)
                mat[ , xvars] %*% coefi
        }
        
        y_pred <- 
                map_dfc(tbestsel$model.number, 
                        predict.regsubsets, 
                        object = mod_fit, formula = mod_form, newdata = data_in)
        
        mse.calculate <- function(y_pred, y_data){
                mean((as.vector(y_pred) - y_data)^2)
        }
        
        mse.error <- 
                map_dbl(y_pred, 
                        mse.calculate, 
                        y_data = data_in %>% select(!!data_pred) %>% pull())
        
        rez <- ls()
        
        rez$tbl <-
                bind_cols(
                        tbestsel,
                        mse = mse.error
                )
        
        rez$graph <- 
                ggplot(data = rez$tbl) +
                geom_line(aes(x = model.number, y = mse, group = 1)) +
                geom_point(aes(x = model.number, y = mse), size = 3) +
                xlab("model.number")
        
        rez
}