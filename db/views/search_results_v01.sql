SELECT
  issues.id AS id,
  issues.summary AS summary,
  issues.description AS description,
  issues.closed AS closed,
  issues.opened_at AS opened_at,
  issues.issue_type_id AS issue_type_id,
  issues.user_id AS user_id,
  issues.project_id AS project_id,
  null AS issue_id,
  'Issue' AS class_name,
  issues.created_at AS created_at,
  issues.updated_at AS updated_at
FROM issues

UNION

SELECT
  tasks.id AS id,
  tasks.summary AS summary,
  tasks.description AS description,
  tasks.closed AS closed,
  tasks.opened_at AS opened_at,
  tasks.task_type_id AS task_type_id,
  tasks.user_id AS user_id,
  tasks.project_id AS project_id,
  tasks.issue_id AS issue_id,
  'Task' AS class_name,
  tasks.created_at AS created_at,
  tasks.updated_at AS updated_at
FROM tasks
