
using Jchemo, JchemoData
using JLD2, CairoMakie


using JchemoData, JLD2, CairoMakie, GLMakie
path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/cassav.jld2")
@load db dat
@names dat


X = dat.X 
Y = dat.Y 
year = Y.year ;
tab(year)


s = year .<= 2012 ;
@head Xtrain = X[s, :] 
@head Xtest = rmrow(X, s) 
ntrain = nro(Xtrain) 
ntest = nro(Xtest)


model0 = pcasvd(nlv = 10) 
fit!(model0, Xtrain)  
fitm0 = model0.fitm ; 
@names fitm0


model = occsdod()
fit!(model, fitm0, Xtrain)
fitm = model.fitm ;
@names fitm
@head dtrain = fitm.d


res = predict(model, Xtest) ;
@names res
@head dtest = res.d


d = vcat(dtrain, dtest) ;
group = [repeat(["Train"], ntrain); repeat(["Test"], ntest)] ;
color = [(:red, .5), (:blue, .5)]
plotxy(d.d_sd, d.d_od, group; zeros = true, color, xlabel = "SD", ylabel = "OD").f

