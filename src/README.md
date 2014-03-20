# Latent Dirichlet Allocation implementation

Implementation details. Do not get bored...

* [Parameter estimation for text analysis](http://www.arbylon.net/publications/text-est.pdf) by Heinrich.

## Quick recap

Latent Dirichlet Allocation (LDA) can be solved by several methods. 

### A prelude about variational methods

In the paper by Blei, Ng, and Jordan (called "Latent Dirichlet Allocation") a variational method is used. A lower
bound to LDA can be found by severing edges in its graphical model representation. This results in a simplified
family of probability distributions and some new parameters, not originally present in the model. These variational
parameters do not depend on each other and their values can be found by comparing the probability distributions they
generate with the true posterior. The difference with the description for the true posterior and the simplified 
probability distribution is the so-called Kullback-Leibler divergence. This is the entity that has to be miminized,
so its derivative is set to zero. Solving the equations resulting from this can be done through an iterative 
procedure. Note, that the original paper leaves a lot of details out. For example the sum in Eq.8 is not shown in
the pseudocode in Fig.6. This is because thanks to the normalization on line 7 in Fig.6, this becomes an irrelevant
constant. However, we choose here to go for Gibbs sampling for another reason, namely general applicability. A
variational method is craftmanship tailored to a specific situation.

### Gibbs sampling
The implementation in this repository performs Gibbs sampling. Gibbs sampling starts with (boldly) assigning values 
for all variables involved. Then one of these variables is picked out and its value is recalculated 
assuming all the other values are correct. A next variable is picked, until the entire set of variables converges to
certain values. And even that is not necessary. After a certain "burn-in period" it suffices to run the Gibbs sampler
for a while and average the values of the variables after that period. Because the updates of the Gibbs sampler only
adjust the solution each step for just a little bit it is advisable to only consider samples each S steps.

In this context calculating one variable given all others is given as a conditional probability. The form of this 
conditional probability is important.

The terms and mixtures are related through the non-unique words in a document by so-called indicator variables, with 
`z` indicating the mixture, and `w` indicating the word. The vectors `z` and `w` are the same length: the total number 
of words.

The conditional probability we are after, is, as always, a joint probability divided by the marginal probability upon
which it is conditioned:

    p(z|w) = p(z,w)/p(w) 

And the joint probability we can write as a simple multiplication:

    p(z,w) = \prod_{i=1}^W p(z_i, w_i)

The marginal `p(w)` is this same product but summed over all possible values of `z_i`. Note that this notation that 
iterates over all non-unique samples (words) has to store the same value `p(z_i, w_i)` for identical words.

Now Gibbs sampling amounts to the conditional:

    p(z_i|z_-i, w)

Here the notation `z_-i` signifies the set `z`, but with `z_i` removed. Naturally:

    p(z_i|z_-i, w) = p(z_i,z_-i,w) / p(z_-i,w) = p(z,w) / p(z_-i,w)
    

## Algorithm

The pseudocode for the algorithm is as follows (see referenced document above):

    zero all count variables
    for all documents m 
      for all words n in document m
        sample topic index z_{mn} = k \sim Mult(1/K)
        increment document-topic count: n_m^k + 1
        increment document-topic sum: n_m + 1
        increment term-topic count: n_k^t + 1
        increment term-topic sum: n_k + 1
    while not converged
      for all documents m
        for all words n in document m
          get current topic-term assignment: (k, t)
          decrement counts and sums: n_m^k - 1, n_m - 1, n_k^t - 1, n_k - 1
          sample topic: k \sim p(z_i|z_-i, w)
          set new topic-term assignment (k, t)
          increment counts and sums
      set converged to true if converged
    set parameters \phi and \theta

The parameters `\phi` and `\theta` are chosen such that they form a conjugate prior with the multinomial distributions,
namely by using a Dirichlet prior for them. This means that they not need to be sampled (and hence you see them here
outside of the while loop). The uncertainty related to this parameters is captured analytically.

There are also hyper-parameters, such as `\alpha` who are used for the above mentioned Dirichlet distribution. These 
are set currently by the user in the configuration file. Estimation of these values is actually extremely important, 
because topic models are typically quite sensitive to them. 

Sampling procedure of the topic:

    p(z_i=j|z_-i,w) \propto (N_0 + \beta) / (N_1 + W*\beta) * (N_2 + \alpha) / (N_3 + T*\alpha)

Here `N_0, ..., N_3` are different frequency terms:

    N_0: number of instances of word w assigned to topic j, not including current word
    N_1: total number of words assigned to topic j, not including current word
    N_2: number of words in document d_i assigned to topic j, not including current word
    N_3: total number of words in document d_i, not including current word

## Structure

The following remarks have to be taken as suggestions for improvement or perhaps a todo list.

The code does not make use of STL functionality. For example in `model::sampling`, `p[k]` is accumulated by running 
over a for loop, and it is assumed the reader understands the sum will be in `p[K-1]`. Use of `std::accumulate` would
be appropriate.

The next code block iterates over the same array and returns the index if the value is beyond a threshold. The STL
function is called `std::upper_bound`, and returns the first element greater than the given value. Using STL containers 
makes functions easier to read especially if a comment explains WHY you want this value.

The code does use double arrays `[][]`, probably originating from the original matlab code. However, it would be much 
easier to have a data structure that fits any probability (or frequency) you would like to define. In the current setup
it seems quite hard to extend the model to a different structure. The structure that defines a probability in a general
sense is an `nd-array`. Also writing test units becomes much easier if the data structures become first-class citizens.

In `utils::quicksort` there is a quicksort implementation. This is only used in saving models, so its performance does
not matter, but it is wiser to use STL `std::sort` because its likely to have an efficient implementation. For instance, 
the implementation uses in-place swaps, nice, however, the pivot is set to the leftmost item. This is the worst case
scenario for an already sorted array. Anyway, who knows what might best, the library should sort that out. It might be
something relative unknown yet, such as [TimSort](https://en.wikipedia.org/wiki/Timsort).

## Copyrights

Copyrights with respect to comments and analysis: Anne van Rossum

Same GPL license of course.

Responsabilities for actually believing my remarks are yours. :-)
