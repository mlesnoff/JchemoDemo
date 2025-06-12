
using Jchemo, JchemoData
using JLD2, CairoMakie
using FreqTables 
using CodecZlib   # required since mnist20pct.jld2 is compressed


path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/mnist20pct.jld2") 
@load db dat
@names dat


Xtrain = dat.Xtrain
ytrain = dat.ytrain
Xtest = dat.Xtest
ytest = dat.ytest
ntrain, p = size(Xtrain)
ntest = nro(Xtest)
ntot = ntrain + ntest
(ntot = ntot, ntrain, ntest)


tab(ytrain)


tab(ytest)


@head Xtrain = Matrix(Xtrain) / 255


@head Xtest = Matrix(Xtest) / 255


plotsp(Xtrain, 1:p; nsamp = 1, xlabel = "Pixel", ylabel = "Grey level").f


model = plsqda(nlv = 25)
fit!(model, Xtrain, ytrain)
pred = predict(model, Xtest).pred


errp(pred, ytest)  # overall


merrp(pred, ytest) # average by class


res = freqtable(ytest, vec(pred))


round.(100 * res ./ rowsum(res); digits = 1)


cf = conf(pred, ytest)
@names cf


cf.cnt


cf.pct


cf.diagpct


cf.accpct


plotconf(cf).f


plotconf(cf; cnt = false).f

