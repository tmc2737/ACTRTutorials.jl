### A Pluto.jl notebook ###
# v0.19.9

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 7396e418-6ed8-11ec-0921-452cc5cdf6fb
begin
	using PlutoUI, Distributions, Plots, Random, ACTRModels
	using CommonMark
	TableOfContents()
end

# ╔═╡ fbbd81b6-5a5d-4ca2-a732-2a9682680982
md"
# Evidence Accumulation Models

Evidence accumulation models are a popular class of models that have been successful in describing the dynamics of many cognitive processes, including memory retrieval (Ratcliff, 1978), decision making (Roe et al., 2001) and perception, among others (Forstmann et al., 2016). The basic idea that underlies evidence accumulation models is that cognitive processes, such decision making and memory retrieval, involve the dynamic accumulation of evidence across time and a response is given when the evidence for one alternative reaches a threshold first. Models within this broad class are based on different assumptions about the accumulation process. Some assume evidence accumulation is an independent race to a decision treshold while others assume evidence for one response can inhibit evidence for other responses. However, they all share the following core assumptions:


1. evidence for each response option accumulates gradually over time. 
2. a response is triggered as soon the evidence for an alternative reaches a decision threshold. 


We will briefly review a few popular evidence accumulation models before describing how the Lognormal race model fits well retrieval dynamics of ACT-R.


## Drift Diffusion Model 

The figure (Tseng, et al., 2014) below illustrates the evidence accumulation process of the drift diffusion model (Ratcliff, 1978). Evidence at each time point represents the difference between the two available options: red or green. 
"

# ╔═╡ 87470312-d8e7-4ee3-a197-bb9441c78380
let
	url = "https://i.imgur.com/4iTriQc.png"
	data = read(download(url))
	PlutoUI.Show(MIME"image/png"(), data)
end

# ╔═╡ 2e267229-4106-4ece-a65c-d52db0163cb4
md"
## Linear Ballistic Accumulator

Alternatively, the Linear Ballistic Accumulator (LBA) assumes evidence in multiple independent accumulators race towards a threshold in a linear fashion (Brown & Heathcote, 2008). The LBA naturally extends to paradigms using more than two response options. An illustration of the LBA is found below (van Maanen & Miletić, 2020):
"

# ╔═╡ 7a63acc6-049b-44ff-bdca-4a9041b4410a
let
	url = "https://i.imgur.com/tA6OFb8.png"
	data = read(download(url))
	PlutoUI.Show(MIME"image/png"(), data)
end

# ╔═╡ 5314d721-07b9-4800-98d3-72da18e80bdf
md"
# Lognormal Race Process


As detailed in Fisher et al. (2020) and  Nicenboim & Vasishth (2018), memory retrieval process in ACT-R can be described by a particular sequential sampling model called the Lognormal Race (LNR) Model (Rouder et al., 2015). As the name implies, the time for an individual accumulator to reach the threshold follows a Lognormal distribution. The figure below, taken from Nicenboim & Vasishth (2018), illustrates the mechanics of the LNR as a sequential sampling process. As you can see, the LNR and LBA are both based on independent accumulators, but the LNR does not assume variability in initial evidence values, making it a simpler model. 
"

# ╔═╡ 5bf690a1-fdb0-4a83-97db-46ea84baa69a
let
	url = "https://i.imgur.com/AR9ryCi.png"
	data = read(download(url))
	PlutoUI.Show(MIME"image/png"(), data)
end

# ╔═╡ 2bc82ee2-39b9-47d2-b66b-9ad0229387b4
md"

## Instantiating Memory Retrieval as a Lognormal Race Process

Within the LNR framework, each eligible chunk $m$ is represented by an evidence accumulator in which evidence accumulates at a rate that is proportional to activation $a_m$. At the beginning of a trial, evidence in each evidence accumulator starts at zero and accrues to a threshold $b$. The first accumulator to reach threshold $b$ determines which chunk is retrieved. It is important to note that evidence accumulation rate and the threshold cannot be mathematically disentangled without further assumptions. This is the case because the slope in the figure includes both $b$ and $a$. Nonetheless, the LNR is useful for defining likelihood functions for ACT-R.

### Activation

In this section, we outline the relationship between the LNR and memory retrieval in ACT-R. Recall that activation for chunk $m$ can be represented as a deterministic component $\mu_m$ and a stochastic component $\epsilon_m$. Thus, activation is defined as:

$\begin{align}
a_m = \mu_m + \epsilon_m
\end{align}$

such that $\epsilon_m \sim \rm normal(0, \sigma)$ and the expected value $E[a_m] = \mu_m$. The plot below illustrates the distribution of activation for chunk $m$.
"

# ╔═╡ e509ef18-e48e-463a-81af-49f7b2e41f0a
begin

	# base level constant
	_blc = 1.5
	# standard deviation in log space
	σ = 0.4
	# number of activation samples
	n = 10_000
	# normally distributed activation noise
	ϵ = rand(Normal(0, σ), n)
	# activation values
	a = _blc .+ ϵ
	# create histogram of activations
	histogram(a, leg=false, grid=false,color=:grey, size=(600,400), xlabel="Activation", ylabel="Frequency",
		xaxis=font(12), yaxis=font(12))# activation values
end

# ╔═╡ b6a43593-83eb-4989-bf08-2b4f7c7b8a8c
md"

### Retrieval Time

In ACT-R, retrieval time is a monotonically decreasing function of activation: as activation increases, reaction time decreases. In particular, retrieval time is related to the following distribution:

$\begin{align}
t_m \sim e^{-a_m}
\end{align}$

where $t_m$ is the retrieval time for chunk $m$, and $a_m$ is the activation for chunk $m$. Notice that the calculation of retrieval time uses negative activation as an exponent for the base of the natural logarithm. This produces two important results. First, it introduces skew into the distribution of retrieval time, which is commonly observed in empirical data. This happens even though activation noise is normally distributed. Second, it ensures that higher activation, leads to faster retrieval times. The code block below illustrates how the transformation using the equation above produces a skewed distribution of retrieval times. 
	"

# ╔═╡ 71408957-8a04-4891-b8b2-0a90c461b7de
begin
	# transform activation to retrieval time
	t  = exp.(-a)
	# create histogram of retrieval times
	histogram(t, leg=false, grid=false,color=:grey, size=(600,400), xlabel="Retrieval Time (seconds)", ylabel="Frequency",
	    xaxis=font(12), yaxis=font(12))
end

# ╔═╡ 4a4bdbf0-bba8-4052-bd21-9436efa5756d
md"
### Lognormal Distribution

Retrieval time in ACT-R follows what is known as a Lognormal distribution. Hence, the relationship between memory retrieval in ACT-R and the LNR. A random variable $X$ follows a Lognormal distribution if $\rm log(X) \sim \rm Normal(\mu,\sigma)$. Formally, we can write the previous equation directly in terms of the Lognormal distribution:


$\begin{align}
    t_m \sim \rm Lognormal(-\mu_m, \sigma)
\end{align}$

where $\sigma = \frac{s\pi}{\sqrt{3}}$. The PDF of the Lognormal distribution is defined as: 

$\begin{align}
f(t; \mu, \sigma) = \frac{1}{t\sigma \sqrt{2\pi}}e^{- \frac{\left(log(t)-\mu\right)^2}{2\sigma^2} } 
\end{align}$

and the corresponding CDF of the Lognormal distribution is defined as:

$\begin{align}
        F(t; \mu, \sigma) = \frac{1}{2} + \frac{1}{2}\textrm{erf}\left(\frac{\rm log(t)-\mu}{\sqrt{2}\sigma} \right)
\end{align}$

The following code block overlays the Lognormal PDF over the histogram to demonstrate the the simulated retrieval times do indeed follow a Lognormal distribution.
"

# ╔═╡ b3b2905a-6d49-4004-8ba6-62ce78b7644b
let
	x = 0.0:0.01:.8
		# base level constant
	_blc = 1.5
	# standard deviation in log space
	σ = 0.4
	densities = pdf.(LogNormal(-_blc, σ), x)
	histogram(t, leg=false, grid=false,color=:grey, size=(600,400), xlabel="Retrieval Time (seconds)", ylabel="Density",
	    xaxis=font(12), yaxis=font(12), norm=true)
	plot!(x, densities, linewidth=2)
end

# ╔═╡ e553ab0e-bd89-496d-99f4-a8142cca4b47
md"
### Retrieval Failures

How do we represent a retrieval failure in the Lognormal Race model? Much like a chunk, we assign the retrieval failure response to an evidence accumulator. Thus, the deterministic component of activation for a retrieval failure is equal to the retrieval threshold: $\mu_{m^\prime} = \tau$. This treatment of retrieval failures marks a departure from standard ACT-R, which assumes that retrieval failures are deterministic. However, assuming a deterministic time for retrieval failures is not very tenable. This modification improves the plausibility of the model, but does have the effect of changing the mean retrieval failure time from $\tau$ to $e^{\tau + \frac{\sigma^2}{2}}$, which is the mean of the Lognormal distribution. 

### Differences from Standard ACT-R

The standard implementation differs from the Lognormal Race in two respects: the use of Logistic as opposed to Gaussian activation noise, and the use of a deterministic retrieval deadline. We performed two parameter recovery simulations to understand how these implementational details affect relationship between parameters. In the both simulations, we generated 500 datasets containing 100 observations from a Loglogistic Race and fit the Lognormal Race model to each data set. The models had three accumulators with the last one designated as the response deadline. The true values were sampled from a uniform distribution as follows: $\mu_i \sim \textrm{Uniform}(-1.5,1.5)$ and $s \sim \textrm{Uniform}(.3, 1)$. The priors for the Lognormal Race model were $\mu_i \sim \textrm{Normal}(0,1)$ and $s \sim \textrm{Cauchy}(0, 1)_{0}^{\infty}$. In one simulation, the retrieval deadline was stochastic, whereas in the other simulation, the retrieval deadline was deterministic.
 
The first figure shows that the parameters are recovered accurately when the data-generating model has a stochastic retrieval deadline. However, the $\mu$ parameters differ when the data-generating model uses a deterministic threshold. The recovered retrieval deadline parameter is lower in order to compensate for the increase in retrieval failures resulting from increased noise. In addition, increased noise will increase the expected time because $E[y] = e^{\mu + \sigma^2/2}$ for a Lognormally distributed random variable. The deterministic threshold also affected the recovered values for the other $\mu$ parameters, but to a lessor extent.

#### Stochastic Threshold 

| parm | intercept | slope | correlation |
|------|-----------|-------|-------------|
| μ1   | -0.051    | 0.984 | 0.974       |
| μ2   | -0.044    | 0.976 | 0.972       |
| μ3   | -0.050    | 0.996 | 0.968       |
| s    | 0.002     | 1.022 | 0.961       |


#### Deterministic Threshold


| parm | intercept | slope | correlation |
|------|-----------|-------|-------------|
| μ1   | 0.273     | 0.737 | 0.835       |
| μ2   | 0.258     | 0.771 | 0.866       |
| μ3   | -0.596    | 1.309 | 0.956       |
| s    | -0.014    | 0.814 | 0.743       |
"

# ╔═╡ 6f969efe-6f72-4a92-bb31-60cc0d6b014b
md"
### Retrieval Dynamics

Declarative memory contains a set of chunks $M$. The retrieval dynamics in ACT-R begin when a production rule $\mathbf{p}$ issues a retrieval request $\mathbf{r}$ to the declarative memory module (clock [here](Notation.ipynb) for an explanation of notation). Once the retrieval request has been issued, a sub-set of eligible chunks $R \subset M$ race towards the retrieval threshold. The winner of this race is retrieved and stored temporarily in the retrieval buffer.  

The substantive interpretation in terms of ACT-R is that an accumulator accrues evidence for the match between its corresponding memory chunk and the retrieval request. The chunk with the greatest mean activation will tend to win the race. The Lognormal Race model is well-suited for ACT-R because it assumes retrieval times are Lognormally distributed and that the chunk with highest activation is selected. 

### Perceptual-Motor Process

The LNR makes the simplifying assumption that non-memory processes, such as perceptual-motor processes and conflict resolution, can be represented by a single parameter $t_{\textrm{er}}$. Although this simplifying assumption is almost certainly wrong, it makes the likelihood function below much more tractable. In fact, this assumption is often made implictly in most applications of ACT-R, which set `:randomize-time nil` and leave memory retrieval as the sole source of random variation. Typically, $t_{\textrm{er}}$ is estimated from data. However, with ACT-R, $t_{\textrm{er}}$ can be informed by default parameter values (i.e. conflict resolution is 50ms). 

The assumptions of the LNR are summarized as follows:


- each eligible chunk is represented by an evidence accumulator
- the evidence accumulation rate is proportional to activation
- evidence in each accumulator accrues independently
- the first accumulator to reach a threshold will determine the response
- the threshold cannot be disentagled from the evidence accumulation rate without further assumptions
- the time to reach the threshold is Lognormally distrbuted for each accumulator
"

# ╔═╡ fc785400-fbe6-4357-a39a-d5aba6f67696
md"
# Likelihood Function

The likelihood function for the LNR is based on what is called a minimum processing time. We want to know the likelihood that a specific chunk won the race at time $t = \textrm{rt} -t_{\textrm{ter}}$ while the losing chunks are still racing at time $t$. Before providing a general formula for the likelihood function for the LNR, let's develop the likelihood function for a simple case.

Suppose two chunks are eligible for retrieval: chunk 1 and chunk 2. Suppose further that 

- chunk 1 has an expected activation of $\mu_1 = 1$
- chunk 2 has an expected activation of $\mu_2 = .5$
- chunk 1 was retrieved at $t=.5$ seconds.

We are often interested in computing the likelihood of retrieving chunk 1 at .5. Phrased more specifically: what is the likelihood that chunk 1 wins the race at .5 seconds *and* chunk 2 finishes at some unknown later time? In this example, we are dealing with a joint statement because we specified two conditions: chunk 1 won at .5 seconds and chunk 2 finished sometime after .5 seconds. This means we will have two components. The first component is given by the Lognormal probability density function (PDF): $g(t \mid μ_1,\sigma)$. In code, we can write:
"

# ╔═╡ 1886ac89-dfb0-4f30-bd8f-bf23ea4fab84
likelihood_c1_won = pdf(LogNormal(-1, .3), .5)

# ╔═╡ 66da7473-fd53-49aa-a087-b7c5e65c8ab1
md"
In computing the likelihood that chunk 1 won the race, we also need to consider the speed of its competitor chunk 2. If chunk 2 tends to be faster than chunk 1, the victory of chunk 1 should be unlikely. By contrast, if chunk 2 tends to be slower than chunk 1, then the victory of chunk 1 should be likely. To incorporate this information into the likelihood function, we compute the probability that chunk 2 finishes some time after .5 seconds. We do not know exactly when chunk 2 finishes the race, adide from the fact that it must be sometime after .5 seconds. We will use the survivor function to compute this probability. The survivor function is 

$S(t) = P(T>t) = 1 - G(t \mid \mu_2,\sigma))$

where $T$ is a random variable for the finishing time of chunk 2, $t=.5$ is the finishing time of chunk 1, and $G(t \mid \mu_2,\sigma)$ is the lognormal cumulative density function (CDF) for chunk 2. In this case, the CDF is the probability that chunk 2 finishes at $t=.5$ or sooner: $P(T \leq t) = G(t \mid \mu_2,\sigma)$. Of course, since we know that chunk 2 finished after $t=.5$ seconds, we use the complimentary probability: $1 - G(t \mid \mu_2,\sigma))$. In code, the probability that chunk 2 finished *after* .5 seconds is: 
"

# ╔═╡ c2b0efd3-6d38-45f3-8ac4-92212d65ecab
likelihood_c2_still_racing = 1 - cdf(LogNormal(-.5, .3), .5)

# ╔═╡ 638702b5-ed28-40ed-818b-4974ff8f3a8a
md"

Since these events occured together and we assume each chunk races independently, we must multiply the previous two quantities: $g(t \mid \mu_2) \left[1 - G(t \mid \mu_2, \sigma) \right]$. The corresponding code is provided below:

"

# ╔═╡ 11c8053c-7e09-4110-8d17-a82a95aa82d1
likelihood_c1_won * likelihood_c2_still_racing

# ╔═╡ a2f97cee-2a9d-4158-a97a-c827af385271
win_time = @bind win_time Slider(0.0:.05:2.0, default=.50, show_value=true)

# ╔═╡ 8d707e66-515b-4867-b029-b65f9def793f
cm"""
The interactive plot below visualizes the calculation of the likelihood. The density of the finishing times for chunk 1 and chunk 2 are plotted in the top and bottom panel, respectively. The dashed line represents the time of the winning chunk (i.e. the one that was retrieved), which is ``t = ``$(win_time). The shaded blue area under the curve of the other density plot represents possible finishing times of the losing chunk, which is to the right of the dashed verticle line representing the finish time of the winning chunk. The sliders below the figure allow you to change the winner, the finish time of the winner and the mean activation of chunk 1. The likelihood is displayed below the plots. 
"""

# ╔═╡ 1e63eae6-bec5-444d-b8cd-81223464ba72
winner = @bind winner Slider(1:2, default=1, show_value=true)

# ╔═╡ 08255ef6-79ba-4cd5-9026-43690c82e997
μ₁ = @bind μ₁ Slider(-1:.1:2, default=1, show_value=true)

# ╔═╡ 06aa45ef-adb4-45c7-bbee-fd98d0d76da9
begin
	p_win = 0.0
	p_lose = 0.0
	let
		blc = μ₁
		τ = 0.5
		σ = .3
		# range of rt values for x-axis
		times = 0.01:0.005:1.8
		# density for correct rts
		density_correct = @. pdf(LogNormal(-blc, σ), times)
		# plot correct density
		p = plot(
			layout = (2,1), 
			leg = false, 
			xlabel = "Finish Time (seconds)", 
			ylabel = "Density", 
			xlims = (0,2.5),
			ylims = (0,6)
		)
		plot!(times, density_correct, linewidth=2, color=:darkorange, grid=false,
		title="chunk 1")
	
		density_incorrect = map(x-> pdf(LogNormal(-τ, σ), x), times)
		plot!(times, color=:darkorange, density_incorrect, linewidth=2, subplot=2,
			title="chunk 2")
	
		if winner == 1
			ix = times .> win_time
			plot!(times[ix], density_incorrect[ix], fillrange = zero(times[ix]), fc=:blues, subplot=2)
			vline!([win_time], color=:black, linestyle=:dash, subplot=1)
			
			p_win = round(pdf(LogNormal(-blc, σ),win_time), digits=3)
			p_lose = round(1 - cdf(LogNormal(-τ, σ), win_time), digits=3)
			annotate!(2.5, 4, text("g($(win_time) | $(blc)) = $(p_win)", :black, :right, 12), subplot=1)
			annotate!(2.5, 4, text("1 - G($(win_time) | $(τ)) = $(p_lose)", :black, :right, 12), subplot=2)
		else
			ix = times .> win_time
			plot!(times[ix], density_correct[ix], fillrange = zero(times[ix]), fc=:blues, subplot=1)
			vline!([win_time], color=:black, linestyle=:dash, subplot=2)
			
			p_win = round(pdf(LogNormal(-τ, σ), win_time), digits=3)
			p_lose = round(1 - cdf(LogNormal(-blc, σ), win_time), digits=3)
			annotate!(2.5, 4, text("g($(win_time) | $(τ)) = $(p_win)", :black, :right, 12), subplot=2)
			annotate!(2.5, 4, text("1 - G($(win_time) | $(blc)) = $(p_lose)", :black, :right, 12), subplot=1)
		end
	end
end

# ╔═╡ bd08d115-f1d0-4f73-8519-7210e1863f02
if winner == 1
cm"""


<div align="center">


``f_{\textrm{LNR}}(\Theta; t=`` $(win_time)``) = g(t=``$(win_time) ``\mid μ_1 =`` $(μ₁)``,\sigma=``$(.3)``) [1 - G(t=``$(win_time)``; \mu_2 = ``$(.5)``,\sigma=``$(.3)``) ] = ``$(string(round.(p_win * p_lose, digits=3)))

</div>
"""
else

cm"""


<div align="center">


``f_{\textrm{LNR}}(\Theta; t=`` $(win_time)``) = g(t=``$(win_time) ``\mid μ_2 =`` $(.5)``,\sigma=``$(.3)``) [1 - G(t=``$(win_time)``; \mu_1 = ``$(μ₁)``,\sigma=``$(.3)``) ] = ``$(string(round.(p_win * p_lose, digits=3)))

</div>
"""
end

# ╔═╡ d369444c-0583-445c-981b-acada9f89ef3
begin
	function simulate(parms; blc, τ)
	    # Create chunk
	    chunks = [Chunk()]
	    # add chunk to declarative memory
	    memory = Declarative(;memory=chunks)
	    # create ACTR object and pass parameters
	    actr = ACTR(;declarative=memory, parms..., blc, τ)
	    # retrieve chunk
	    chunk = retrieve(actr)
	    # 2 if empty, 1 otherwise
	    resp = isempty(chunk) ? resp = 2 : 1
	    # compute reaction time 
	    rt = compute_RT(actr, chunk) + actr.parms.ter
	    return (resp = resp,rt = rt)
	end
	
	function computeLL(blc, τ, parms, data)
		(;s,ter) = parms
		LL = 0.0
		σ = s * pi / sqrt(3)
		# define distribution object
		dist = LNR(;μ=-[blc,τ], σ, ϕ=ter)
		# compute log likelihood for each data point
		for d in data
			LL += logpdf(dist, d...)
		end
		return LL
	end
	
	nothing
end

# ╔═╡ 60cb549e-e82d-4ea1-bc47-8af4c3b0a7b3
md"

In what follows, we will define a general expression for the likelihood of retrieving a chunk $\mathbf{c}_r$ among a set of chunks in declarative memory. Let $\mathbf{c}_r$ be the result of the retrieval request (either a chunk or a retrieval failure), rt be the response time, and $\Theta = \left\{\mu_1,\dots,\mu_n,\mu_{m^\prime},t_{\textrm{er}}, \sigma\right\}$ be the parameters of the LNR. The joint choice-rt likelihood function for retrieving chunk $\mathbf{c}_r$  at rt is defined as:

$\begin{equation}
f_{\rm LNR}(\Theta;\mathbf{c}_r,\textrm{rt}) = g(\textrm{rt}-t_{\textrm{er}} \mid - \mu_m, \sigma) \prod_{k \in R \cup \mathbf{c}_{m^\prime} \setminus \mathbf{c}_r}\left[1-G(\textrm{rt}-t_{\textrm{er}}|-\mu_k,\sigma)\right]
\end{equation}$

In the equation above, $\mu_m$ is the activation of chunk $m$ , $\sigma$ is the standard deviation, $g$ is the Lognormal PDF, $G$ is the Lognormal CDF, $R\cup \mathbf{c}_{m}^\prime$ is the set of candidate chunks for a retrieval request, $m^\prime$ is an index for a retrieval failure,  and $t_{\rm er}$ refers to the processing time not attributable to memory retrieval time. The likelihood function consists of two primary terms:

-  $g(\textrm{rt}-t_{\textrm{er}} \mid - \mu_m, \sigma)$ is the likelihood that chunk $m$ is retrieved at time rt $-t_{\rm er}$

-  $\prod_{k \in R \cup \mathbf{c}_{m^\prime} \setminus \mathbf{c}_m}\left[1-G(\textrm{rt}-t_{\textrm{er}}|-\mu_k,\sigma)\right]$ is the probability that all other chunks have *not* reached the threshold by time rt $- t_{\rm er}$

Thus, the likelihood function captures the fact that chunk $m$ won the race at a specific time while the other chunks have not reached the threshold. 

"

# ╔═╡ 3cf41e46-be57-49ef-882b-88f2f7aa1325
md" 
# Using LNR with ACTRModels.jl

Combining the LNR with ACTModels.jl is simple.
## Define a model

We will begin by defining a model based on three addition facts. The function `Chunk` is a constructor for a chunk object. In the code below, each chunk consists of slots `num1` for the first addend, `num2` for the second addend, and `sum` for the sum of the two addends. 
"

# ╔═╡ 8a2b5327-a73d-4bb9-a2b5-4d4934976107
# create a vector of chunks representing addition facts
chunks = [Chunk(num1=2,num2=1,sum=3),Chunk(num1=2,num2=2,sum=4),Chunk(num1=1,num2=1,sum=2)]

# ╔═╡ 2c056b06-680c-4a7f-837b-0fbed56dd34e
md"

Next, we add the chunks to the declarative memory object
"

# ╔═╡ 5eb3f63b-d88f-4f93-a5d2-2399835e3a67
# create a declarative memory object
declarative = Declarative(memory=chunks);

# ╔═╡ 82847c7f-788d-48ad-9c61-eee718df1cd2
md"

To create the ACT-R model, we pass the declarative memory object and list of parameters.
"

# ╔═╡ c80f1bf1-42f8-4362-9b3b-8198397b941e
begin
	s = 0.3
	ter = 0.4
	# define the ACTR object and pass the parameters
	actr = ACTR(;declarative, blc=2.0, mmp=true, δ=.5, s, τ=-10);
	nothing# suppress output
end

# ╔═╡ 7bd9a066-1513-4f88-ab32-e6838796c99b
md"
## Compute Activation

In the following code block, we will compute the activation for the retrieval request $\mathbf{r} = \{(\textrm{num}_1,2),(\textrm{num}_2,2)\}$. This involves computing activation with `compute_activation!`, extracting the activation values, and generating the `LNR` object. 
"

# ╔═╡ a9200acb-4c8c-4872-88e7-30b05b91c77b
begin
	# compute the activation with given retrieval request for 2 + 2
	compute_activation!(actr; num1 = 2, num2 = 2)
	# extract the activation values
	μs = map(x->x.act, chunks)
	# compute sigma
	σ1 = s * pi / sqrt(3)
	# create the LNR distribution object
	lnr = LNR(;μ=-μs, σ=σ1, ϕ=ter);
end

# ╔═╡ 29e801c6-b3ec-4e34-8574-f87f7ba2b668
md"
## Plotting the densities

Now that the model and `LNR` objects have been defined, we can plot densities. As expected, the density for $\mathbf{c_m} = \{(\textrm{num}_1,2),(\textrm{num}_2,2),(\textrm{sum},4)\}$ is the highest because it has the highest activation. In addition, the mean reaction time for this chunk is $\approx .52$ compared to $\approx .57$.for the slowest chunk $\mathbf{c_k} = \{(\textrm{num}_1,1),(\textrm{num}_2,1),(\textrm{sum},2)\}$.
"

# ╔═╡ 2ac4adf8-b68c-4db0-9d76-27adf934d4b9
let
	x = ter:0.005:1.0
	choice_idx = 1:3
	dens = map(c->pdf.(lnr, c, x), choice_idx)
	to_string(x) = [string(k, " = ", v) for (k,v) in pairs(x)]
	labels = map(c->to_string(c.slots), chunks)
	labels = reshape(labels, 1, 3)
	plot(x, dens, grid=false, xlabel="RT", ylabel="Density", xlims=(0,1), xaxis=font(12), yaxis=font(12), 
	    linewidth=2, labels=labels, size=(700,400), leg=:topright)
end

# ╔═╡ dfcfec52-10d9-48c3-b9df-85390a61ddc1
md"
# References

Brown, S. D., & Heathcote, A. (2008). The simplest complete model of choice response time: Linear ballistic accumulation. Cognitive psychology, 57(3), 153-178.

Fisher, C. R., Houpt, J. W., & Gunzelmann, G. (2020). Developing memory-based models of ACT-R within a statistical framework. Journal of Mathematical Psychology, 98, 102416.

Forstmann, B. U., Ratcliff, R., & Wagenmakers, E. J. (2016). Sequential sampling models in cognitive neuroscience: Advantages, applications, and extensions. Annual review of psychology, 67.

Nicenboim, B., & Vasishth, S. (2018). Models of retrieval in sentence comprehension: A computational evaluation using Bayesian hierarchical modeling. Journal of Memory and Language, 99, 1-34.

Ratcliff, R. (1978). A theory of memory retrieval. Psychological review, 85(2), 59.

Roe, R. M., Busemeyer, J. R., & Townsend, J. T. (2001). Multialternative decision field theory: A dynamic connectionst model of decision making. Psychological review, 108(2), 370.

Rouder, J. N., Province, J. M., Morey, R. D., Gomez, P., & Heathcote, A. (2015). The lognormal race: A cognitive-process model of choice and latency with desirable psychometric properties. Psychometrika, 80(2), 491-513.

Tseng, Y. C., Glaser, J. I., Caddigan, E., & Lleras, A. (2014). Modeling the effect of selection history on pop-out visual search. PLoS One, 9(3), e89996.

van Maanen, L., & Miletić, S. (2020). The interpretation of behavior-model correlations in unidentified cognitive models. Psychonomic Bulletin & Review, 1-10.
"

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
ACTRModels = "c095b0ea-a6ca-5cbd-afed-dbab2e976880"
CommonMark = "a80b9123-70ca-4bc0-993e-6e3bcb318db6"
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[compat]
ACTRModels = "~0.10.6"
CommonMark = "~0.8.6"
Distributions = "~0.25.62"
Plots = "~1.29.1"
PlutoUI = "~0.7.39"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.3"
manifest_format = "2.0"

[[deps.ACTRModels]]
deps = ["ConcreteStructs", "Distributions", "Parameters", "Pkg", "PrettyTables", "Random", "Reexport", "SafeTestsets", "SequentialSamplingModels", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "54667a26ef188769599a1113fa10614d68783ba9"
uuid = "c095b0ea-a6ca-5cbd-afed-dbab2e976880"
version = "0.10.6"

[[deps.AbstractFFTs]]
deps = ["ChainRulesCore", "LinearAlgebra"]
git-tree-sha1 = "6f1d9bc1c08f9f4a8fa92e3ea3cb50153a1b40d4"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.1.0"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "af92965fb30777147966f58acb05da51c5616b5f"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.3"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "66771c8d21c8ff5e3a93379480a2307ac36863f7"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.1"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.Calculus]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f641eb0a4f00c343bbc32346e1217b86f3ce9dad"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.5.1"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "9489214b993cd42d17f44c36e359bf6a7c919abf"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.0"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "1e315e3f4b0b7ce40feded39c73049692126cf53"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.3"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "7297381ccb5df764549818d9a7d57e45f1057d30"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.18.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "0f4e115f6f34bbe43c19751c90a38b2f380637b9"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.3"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "d08c20eef1f2cbc6e60fd3612ac4340b89fea322"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.9"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[deps.CommonMark]]
deps = ["Crayons", "JSON", "URIs"]
git-tree-sha1 = "4cd7063c9bdebdbd55ede1af70f3c2f48fab4215"
uuid = "a80b9123-70ca-4bc0-993e-6e3bcb318db6"
version = "0.8.6"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "924cdca592bc16f14d2f7006754a621735280b74"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.1.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[deps.ConcreteStructs]]
git-tree-sha1 = "f749037478283d372048690eb3b5f92a79432b34"
uuid = "2569d6c7-a4a2-43d3-a901-331e8e4be471"
version = "0.2.3"

[[deps.Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "fb5f5316dd3fd4c5e7c30a24d50643b73e37cd40"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.10.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.DensityInterface]]
deps = ["InverseFunctions", "Test"]
git-tree-sha1 = "80c3e8639e3353e5d2912fb3a1916b8455e2494b"
uuid = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
version = "0.4.0"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Distributions]]
deps = ["ChainRulesCore", "DensityInterface", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "0ec161f87bf4ab164ff96dfacf4be8ffff2375fd"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.62"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[deps.DualNumbers]]
deps = ["Calculus", "NaNMath", "SpecialFunctions"]
git-tree-sha1 = "5837a837389fccf076445fce071c8ddaea35a566"
uuid = "fa6b7ba4-c1ee-5f82-b5fc-ecf0adba8f74"
version = "0.6.8"

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3f3a2501fa7236e9b911e0f7a588c657e822bb6d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.3+0"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bad72f730e9e91c08d9427d5e8db95478a3c323d"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.4.8+0"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "Pkg", "Zlib_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "d8a578692e3077ac998b50c0217dfd67f21d1e5f"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.0+0"

[[deps.FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "505876577b5481e50d089c1c68899dfb6faebc62"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.4.6"

[[deps.FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c6033cc3892d0ef5bb9cd29b7f2f0331ea5184ea"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.10+0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "246621d23d1f43e3b9c368bf3b72b2331a27c286"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.13.2"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "51d2dfe8e590fbd74e7a842cf6d13d8a2f45dc01"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.6+0"

[[deps.GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "RelocatableFolders", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "b316fd18f5bc025fedcb708332aecb3e13b9b453"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.64.3"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "1e5490a51b4e9d07e8b04836f6008f46b48aaa87"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.64.3+0"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "83ea630384a13fc4f002b77690bc0afeb4255ac9"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.2"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "a32d672ac2c967f3deb8a81d828afc739c838a06"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.68.3+2"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "0fa77022fe4b511826b39c894c90daf5fce3334a"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.17"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.HypergeometricFunctions]]
deps = ["DualNumbers", "LinearAlgebra", "SpecialFunctions", "Test"]
git-tree-sha1 = "cb7099a0109939f16a4d3b572ba8396b1f6c7c31"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.10"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.IniFile]]
git-tree-sha1 = "f550e6e32074c939295eb5ea6de31849ac2c9625"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.1"

[[deps.IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d979e54b71da82f3a65b62553da4fc3d18c9004c"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2018.0.3+2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.Interpolations]]
deps = ["AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "b7bc05649af456efc75d178846f47006c2c4c3c7"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.13.6"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "c6cf981474e7094ce044168d329274d797843467"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.6"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.IterTools]]
git-tree-sha1 = "fa6287a4469f5e048d763df38279ee729fbd44e5"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.4.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b53380851c6e6664204efb2e62cd24fa5c47e4ba"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.2+0"

[[deps.KernelDensity]]
deps = ["Distributions", "DocStringExtensions", "FFTW", "Interpolations", "StatsBase"]
git-tree-sha1 = "591e8dc09ad18386189610acafb970032c519707"
uuid = "5ab0869b-81aa-558d-bb23-cbf5423bbe9b"
version = "0.6.3"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "Printf", "Requires"]
git-tree-sha1 = "46a39b9c58749eefb5f2dc1178cb8fab5332b1ab"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.15"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "7739f837d6447403596a75d19ed01fd08d6f56bf"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.3.0+3"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "3eb79b0ca5764d4799c06699573fd8f533259713"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.4.0+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "09e4b894ce6a976c354a69041a04748180d43637"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.15"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "e595b205efd49508358f7dc670a940c790204629"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2022.0.0+0"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "Random", "Sockets"]
git-tree-sha1 = "1c38e51c3d08ef2278062ebceade0e46cefc96fe"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.0.3"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[deps.Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[deps.NaNMath]]
git-tree-sha1 = "737a5957f387b17e74d4ad2f440eb330b39a62c5"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.0"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[deps.OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "b4975062de00106132d0b01b5962c09f7db7d880"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.12.5"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ab05aa4cc89736e95915b01e7279e61b1bfe33b8"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.14+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.PCRE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b2a7af664e098055a7529ad1a900ded962bca488"
uuid = "2f80f16e-611a-54ab-bc61-aa92de5b98fc"
version = "8.44.0+0"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "3411935b2904d5ad3917dee58c03f0d9e6ca5355"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.11"

[[deps.Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "34c0e9ad262e5f7fc75b10a9952ca7692cfc5fbe"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.3"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "1285416549ccfcdf0c50d4997a94331e88d68413"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.3.1"

[[deps.Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "8162b2f8547bc23876edd0c5181b27702ae58dce"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.0.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "bb16469fd5224100e422f0b027d26c5a25de1200"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.2.0"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "9e42de869561d6bdf8602c57ec557d43538a92f0"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.29.1"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "8d1f54886b9037091edf146b517989fc4a09efec"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.39"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "dfb54c4e414caa595a1f2ed759b160f5a3ddcba5"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.3.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "c6c0f690d0cc7caddb74cef7aa847b824a16b256"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+1"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "78aadffb3efd2155af139781b8a8df1ef279ea39"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.4.2"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Ratios]]
deps = ["Requires"]
git-tree-sha1 = "dc84268fe0e3335a62e315a3a7cf2afa7178a734"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.3"

[[deps.RecipesBase]]
git-tree-sha1 = "6bf3f380ff52ce0832ddd3a2a7b9538ed1bcca7d"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.2.1"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase"]
git-tree-sha1 = "dc1e451e15d90347a7decc4221842a022b011714"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.5.2"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "cdbd3b1338c72ce29d9584fdbe9e9b70eeb5adca"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "0.1.3"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "bf3188feca147ce108c76ad82c2792c57abe7b1f"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.0"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "68db32dff12bb6127bac73c209881191bf0efbb7"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.3.0+0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[deps.SafeTestsets]]
deps = ["Test"]
git-tree-sha1 = "36ebc5622c82eb9324005cc75e7e2cc51181d181"
uuid = "1bc83da4-3b8d-516f-aca4-4fe02f6d838f"
version = "0.0.1"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

[[deps.SequentialSamplingModels]]
deps = ["ConcreteStructs", "Distributions", "Interpolations", "KernelDensity", "Parameters", "PrettyTables", "Random"]
git-tree-sha1 = "d43eb5afe2f6be880d3bd79c9f72b964f12e99a5"
uuid = "0e71a2a6-2b30-4447-8742-d083a85e82d1"
version = "0.1.7"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "a9e798cae4867e3a41cae2dd9eb60c047f1212db"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.6"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "383a578bdf6e6721f480e749d503ebc8405a0b22"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.4.6"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "2c11d7290036fe7aac9038ff312d3b3a2a5bf89e"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.4.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "8977b17906b0a1cc74ab2e3a05faa16cf08a8291"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.16"

[[deps.StatsFuns]]
deps = ["ChainRulesCore", "HypergeometricFunctions", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "5783b877201a82fc0014cbf381e7e6eb130473a4"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.0.1"

[[deps.StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "9abba8f8fb8458e9adf07c8a2377a070674a24f1"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.8"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "5ce79ce186cc678bbb5c5681ca3379d1ddae11a1"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.7.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unzip]]
git-tree-sha1 = "34db80951901073501137bdbc3d5a8e7bbd06670"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.1.2"

[[deps.Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "3e61f0b86f90dacb0bc0e73a0c5a83f6a8636e23"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.19.0+0"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4528479aa01ee1b3b4cd0e6faef0e04cf16466da"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.25.0+0"

[[deps.WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "de67fa59e33ad156a590055375a30b23c40299d3"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.5"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "58443b63fb7e465a8a7210828c91c08b92132dff"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.14+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e45044cd873ded54b6a5bac0eb5c971392cf1927"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.2+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "ece2350174195bb31de1a63bea3a41ae1aa593b6"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "0.9.1+5"
"""

# ╔═╡ Cell order:
# ╟─7396e418-6ed8-11ec-0921-452cc5cdf6fb
# ╟─fbbd81b6-5a5d-4ca2-a732-2a9682680982
# ╟─87470312-d8e7-4ee3-a197-bb9441c78380
# ╟─2e267229-4106-4ece-a65c-d52db0163cb4
# ╟─7a63acc6-049b-44ff-bdca-4a9041b4410a
# ╟─5314d721-07b9-4800-98d3-72da18e80bdf
# ╟─5bf690a1-fdb0-4a83-97db-46ea84baa69a
# ╟─2bc82ee2-39b9-47d2-b66b-9ad0229387b4
# ╟─e509ef18-e48e-463a-81af-49f7b2e41f0a
# ╟─b6a43593-83eb-4989-bf08-2b4f7c7b8a8c
# ╟─71408957-8a04-4891-b8b2-0a90c461b7de
# ╟─4a4bdbf0-bba8-4052-bd21-9436efa5756d
# ╟─b3b2905a-6d49-4004-8ba6-62ce78b7644b
# ╟─e553ab0e-bd89-496d-99f4-a8142cca4b47
# ╟─6f969efe-6f72-4a92-bb31-60cc0d6b014b
# ╟─fc785400-fbe6-4357-a39a-d5aba6f67696
# ╠═1886ac89-dfb0-4f30-bd8f-bf23ea4fab84
# ╟─66da7473-fd53-49aa-a087-b7c5e65c8ab1
# ╠═c2b0efd3-6d38-45f3-8ac4-92212d65ecab
# ╟─638702b5-ed28-40ed-818b-4974ff8f3a8a
# ╠═11c8053c-7e09-4110-8d17-a82a95aa82d1
# ╟─8d707e66-515b-4867-b029-b65f9def793f
# ╟─06aa45ef-adb4-45c7-bbee-fd98d0d76da9
# ╟─bd08d115-f1d0-4f73-8519-7210e1863f02
# ╟─a2f97cee-2a9d-4158-a97a-c827af385271
# ╟─1e63eae6-bec5-444d-b8cd-81223464ba72
# ╟─08255ef6-79ba-4cd5-9026-43690c82e997
# ╟─d369444c-0583-445c-981b-acada9f89ef3
# ╟─60cb549e-e82d-4ea1-bc47-8af4c3b0a7b3
# ╟─3cf41e46-be57-49ef-882b-88f2f7aa1325
# ╠═8a2b5327-a73d-4bb9-a2b5-4d4934976107
# ╟─2c056b06-680c-4a7f-837b-0fbed56dd34e
# ╠═5eb3f63b-d88f-4f93-a5d2-2399835e3a67
# ╟─82847c7f-788d-48ad-9c61-eee718df1cd2
# ╠═c80f1bf1-42f8-4362-9b3b-8198397b941e
# ╟─7bd9a066-1513-4f88-ab32-e6838796c99b
# ╠═a9200acb-4c8c-4872-88e7-30b05b91c77b
# ╟─29e801c6-b3ec-4e34-8574-f87f7ba2b668
# ╟─2ac4adf8-b68c-4db0-9d76-27adf934d4b9
# ╟─dfcfec52-10d9-48c3-b9df-85390a61ddc1
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002