# User/Organization activity status

If nobody from an organization confirmed their user and nobody from an organization logged in in a week we mark that organization as inactive. This effectively stops crawling for new data for that organization.

# Item retention

For non-paying, inactive customers/organizations we keep only 1 month of items in the database. We truncate items older than a month every day. For paying customers, there is no limit, but maybe we should think about introducing one, albeit a much more lenient one.
