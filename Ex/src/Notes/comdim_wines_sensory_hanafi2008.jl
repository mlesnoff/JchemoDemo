
using Jchemo, JchemoData
using JLD2, CairoMakie


path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/wines_sensory.jld2")
@load db dat
@names dat


X1 = dat.X1 
X2 = dat.X2
X3 = dat.X3
X4 = dat.X4
Xbl = [X1, X2, X3, X4]   # Same as: Xbl = [[X1]; [X2]; [X3]; [X4]]


n = nro(X1)
nbl = length(Xbl)


nlv = 3
bscal = :frob
model = comdim(; nlv, bscal)
fit!(model, Xbl)
fitm = model.fitm
@names fitm


@head T = fitm.T


i = 1 
f, ax = plotxy(T[:, i], T[:, i + 1]; zeros = true, xlabel = "PC$i", ylabel = "PC$(i + 1)") 
text!(ax, T[:, i], T[:, i + 1]; text = string.("w", 1:n), fontsize = 15)
f


Tbl = fitm.Tbl


Vbl = fitm.Vbl


k = 1
Tbl[k]


Vbl[k]


res = summary(model, Xbl)
@names res


res.explvarxx


explxbl = res.explxbl  # = specific weights 'lb' when 'bscal = :frob'


rowsum(explxbl)


contrxbl2t = res.contrxbl2t


colsum(contrxbl2t)


z = contrxbl2t
i = 1
f, ax = plotxy(z[:, i], z[:, i + 1]; zeros = true, xlabel = "PC$i", 
    ylabel = "PC$(i + 1)") 
text!(ax, z[:, i], z[:, i + 1]; text = string.("j", 1:nbl), fontsize = 15) 
xlims!(ax, [0, .4]) 
ylims!(ax, [0, .9]) 
f


res.rvxbl2t


corx2t = res.corx2t


z = corx2t 
nvar = nro(z) 
i = 1
f, ax = plotxy(z[:, i], z[:, i + 1]; zeros = true, xlabel = "PC$i", 
    ylabel = "PC$(i + 1)") 
text!(ax, z[:, i], z[:, i + 1]; text = string.("v", 1:nvar), fontsize = 15) 
xlims!(ax, [-1, 1]) 
ylims!(ax, [-1, 1]) 
f


k = 4
v = Vbl[k]
nam = names(Xbl[k])
i = 1
f, ax = plotxy(T[:, i], T[:, i + 1]; zeros = true, xlabel = "PC$i", 
    ylabel = "PC$(i + 1)") 
text!(ax, T[:, i], T[:, i + 1]; text = string.("w", 1:n), fontsize = 15) 
scatter!(ax, v[:, i], v[:, i + 1]) 
text!(ax, v[:, i], v[:, i + 1]; text = nam, fontsize = 15) 
ylims!(ax, [-1, 1]) 
f


k = 4  # fourth block
z = Tbl[k] 
v = Vbl[k] 
nam = names(Xbl[k]) 
i = 1
f, ax = plotxy(z[:, i], z[:, i + 1]; zeros = true, xlabel = "PC$i", 
    ylabel = "PC$(i + 1)", title = string("Block ", k)) 
text!(ax, z[:, i], z[:, i + 1]; text = string.("w", 1:n), fontsize = 15) 
scatter!(ax, v[:, i], v[:, i + 1]) 
text!(ax, v[:, i], v[:, i + 1]; text = nam, fontsize = 15) 
ylims!(ax, [-1, 1]) 
f

