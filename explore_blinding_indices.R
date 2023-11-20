library(BI)
library(tidyverse)

# Simulate data

sim_data <- function(
    N, intercept_no_m,
    intercept_no_sd,
    intercept_yes_m,
    intercept_yes_sd,
    mu_no_m,
    mu_no_sd,
    mu_yes_m,
    mu_yes_sd) {
  # Create a data frame with responses to a blinding question
  # N: number of participants
  # intercept_no_m: mean of the intercept for the "no" response, i.e.
  #   the threshold in a normal distribution when "do not know turns"
  #   into "no"
  # intercept_no_sd: standard deviation of the intercept for the "no"
  #   response
  # intercept_yes_m: mean of the intercept for the "yes" response, i.e.
  #   the threshold in a normal distribution when "no" turns
  #   into "yes"
  # intercept_yes_sd: standard deviation of the intercept for the "yes"
  #   response
  # mu_no_m: mean of the slope for the "no" response, i.e. if the
  #   the treatment group has a different threshold than the placebo
  #   group
  # mu_no_sd: standard deviation of the slope for the "no" response
  # mu_yes_m: mean of the slope for the "yes" response, i.e. if the
  #   the treatment group has a different threshold than the placebo
  #   group
  # mu_yes_sd: standard deviation of the slope for the "yes" response

  n_groups <- 2
  group_size <- N / n_groups
  grouping <- rep(1:n_groups, each = group_size) - 1

  blinding <- rnorm(N, 0, 1)

  intercept_no <- rnorm(N, intercept_no_m, intercept_no_sd)
  intercept_yes <- rnorm(N, intercept_yes_m, intercept_yes_sd)

  mu_no <- rnorm(N, mu_no_m, mu_no_sd)
  mu_yes <- rnorm(N, mu_yes_m, mu_yes_sd)

  thres_no <- intercept_no + grouping * mu_no
  thres_yes <- intercept_yes + grouping * mu_yes

  blinding_reponses <- function(blinding, thres_no, thres_yes) {
    ifelse(blinding < thres_no, "do not know",
      ifelse(blinding < thres_yes, "no", "yes")
    )
  }

  responses <- blinding_reponses(blinding, thres_no, thres_yes)

  df <- data.frame(
    grouping = grouping,
    responses = responses
  )

  df
}

reshape_data <- function(df) {
  # Reshape data frame to a matrix with the number of responses
  response_pivot <- df %>%
    group_by(grouping) %>%
    count(responses) %>%
    pivot_wider(
      names_from = grouping,
      values_from = n,
      values_fill = 0
    ) %>%
    rename(
      Placebo = `0`,
      Treatment = `1`
    )

  response_matrix <- data.matrix(response_pivot[, 2:3])

  response_matrix
}

get_estimators <- function(response_matrix) {
  # Get the estimators for the treatment and placebo group
  blinding_index <- BI(response_matrix)

  treatment <- blinding_index$ BangBI[1, 1]
  placebo <- blinding_index$ BangBI[2, 1]
  james <- blinding_index$ JamesBI[1, 1]
  c(treatment, placebo, james)
}

estimators <- c()

# repeated simulations of responses to the placebo question
# for different values of the mean of the slope for the "yes" response
for (mu_yes_m in seq(-3, 3, 0.5)) {
  for (permutations in 1:1000) {
    print(paste(mu_yes_m, permutations))
    df <- sim_data(
      N = 100,
      intercept_no_m = qnorm(1 / 2),
      intercept_no_sd = 0.1,
      intercept_yes_m = qnorm(2 / 3),
      intercept_yes_sd = 0.1,
      mu_no_m = 0.0,
      mu_no_sd = 0.05,
      mu_yes_m = mu_yes_m,
      mu_yes_sd = 0.05
    )
    response_matrix <- reshape_data(df)
    estimators <- rbind(estimators, c(
      mu_yes_m, get_estimators(response_matrix)
    ))
  }
}

write.table(estimators, "estimators_2.tsv", sep = "\t", row.names = FALSE)

df_bi <- data.frame(
  yes_mu_m = estimators[, 1],
  placebo_bangs_bi = estimators[, 2],
  treatment_bangs_bi = estimators[, 3],
  james_bi = estimators[, 4]
) %>% pivot_longer(
  cols = c(placebo_bangs_bi, treatment_bangs_bi, james_bi),
  names_to = "group", values_to = "bi"
)

ggplot(df_bi, aes(x = yes_mu_m, y = bi, color = group)) +
  geom_smooth() +
  geom_hline(yintercept = 0.2, linetype = "dashed") +
  geom_hline(yintercept = -0.2, linetype = "dashed") +
  theme_bw() +
  scale_color_viridis_d() +
  scale_x_continuous(breaks = seq(-3, 3, 0.5), labels = round(pnorm(
    qnorm(2 / 3) + seq(-3, 3, 0.5)
  ), 4) * 100) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  xlab("Probability of 'yes' response in the group") +
  ylab("Blinding index")
