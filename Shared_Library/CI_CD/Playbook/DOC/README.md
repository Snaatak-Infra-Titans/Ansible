# Ansible Playbook CI/CD — Shared Library Documentation

<p align="center">
  <img src="https://tcude.net/content/images/size/w2000/2022/01/MainImage-17.png" alt="Ansible" width="250"/>
</p>

---

# Document Details

| **Author** | **Created on** | **Version** | **Last Updated By** | **Last Edited On** | **Pre Reviewer** | **L0 Reviewer** | **L1 Reviewer** | **L2 Reviewer** |
| ---------- | -------------- | ----------- | ------------------- | ------------------ | ---------------- | --------------- | --------------- | --------------- |
| Ankita     | 20-07-2026     | v1.0        | Ankita              | 15-08-2026         | Team             | Komal Jaiswal   | Akshit Kapil    | Mahesh Kumar    |

---

# Table of Contents

1. [Introduction](#1-introduction)
2. [What is the Ansible CI/CD Shared Library?](#2-what-is-the-ansible-cicd-shared-library)
3. [Why Use the Shared Library?](#3-why-use-the-shared-library)
4. [Prerequisites](#4-prerequisites)
5. [Supported Shared Library Functions](#5-supported-shared-library-functions)
6. [Jenkins Pipeline Example](#6-jenkins-pipeline-example)
7. [Inputs and Outputs](#7-inputs-and-outputs)
8. [Shared Library Structure](#8-shared-library-structure)
9. [Pipeline Workflow](#9-pipeline-workflow)
10. [Error Handling](#10-error-handling)
11. [Example Commands Executed](#11-example-commands-executed)
12. [Conclusion](#12-conclusion)
13. [Contact Information](#13-contact-information)
14. [References](#14-references)

---

# 1. Introduction

This document provides an overview of the **Ansible Playbook CI/CD Shared Library** used to standardize Ansible playbook validation and execution within Jenkins pipelines.

It covers the purpose of the shared library, supported reusable functions, prerequisites, Jenkins pipeline usage, inputs and outputs, shared library structure, pipeline workflow, error handling, and example Ansible commands.

The document is intended to explain how reusable Jenkins Shared Library components can be used to maintain consistent Ansible playbook CI/CD logic across multiple projects.

---

# 2. What is the Ansible CI/CD Shared Library?

The Ansible CI/CD Shared Library is a reusable Jenkins library that contains common pipeline functions for validating and executing Ansible playbooks.

Rather than implementing the same Ansible commands in every Jenkins pipeline, the common logic is maintained centrally and reused across multiple repositories.

The library provides reusable functions to:

* Validate Ansible playbook syntax
* Execute Ansible playbooks
* Perform dry-run validation
* Standardize CI/CD pipeline logic
* Reduce duplicate Jenkins pipeline code

---

# 3. Why Use the Shared Library?

The shared library provides several advantages:

* Eliminates duplicate Jenkins pipeline code.
* Encourages reusable pipeline components.
* Maintains consistency across multiple projects.
* Simplifies Jenkinsfiles.
* Makes maintenance easier.
* Improves readability and scalability.
* Centralizes common pipeline logic.

---

# 4. Prerequisites

Before using the shared library, ensure the following components are available.

| Tool / Component          | Purpose                                                          |
| ------------------------- | ---------------------------------------------------------------- |
| Jenkins                   | CI/CD Server                                                     |
| Jenkins Shared Library    | Provides reusable pipeline functionality                         |
| Git                       | Source Code Management                                           |
| Python 3.10+              | Required by Ansible                                              |
| Ansible                   | Configuration Management Tool                                    |
| AWS Systems Manager (SSM) | Provides secure access to managed target instances               |
| SSM Agent                 | Enables target instances to communicate with AWS Systems Manager |
| IAM Role                  | Provides permissions required for SSM communication              |
| Inventory File            | Defines target hosts                                             |
| Ansible Playbook          | Contains automation tasks                                        |

---

# 5. Supported Shared Library Functions

The shared library exposes reusable pipeline functions that can be invoked from Jenkins pipelines.

---

## 1. ansibleSyntaxCheck()

Performs syntax validation before executing the playbook.

### Command

```bash
ansible-playbook --syntax-check playbook.yml
```

### Purpose

* Validates playbook syntax
* Detects YAML syntax issues
* Verifies playbook structure
* Prevents execution of invalid playbooks

---

## 2. ansiblePlaybook()

Executes the Ansible playbook using the provided inventory.

### Command

```bash
ansible-playbook -i inventory playbook.yml
```

### Purpose

* Executes the playbook
* Applies configuration to target systems
* Displays execution logs in Jenkins

---

## 3. ansiblePlaybookCheck()

Runs the playbook in Ansible Check Mode.

### Command

```bash
ansible-playbook -i inventory playbook.yml --check
```

### Purpose

* Performs a dry-run validation
* Simulates playbook execution
* Detects possible execution issues
* Makes no changes to target systems

---

# 6. Jenkins Pipeline Example

```groovy
@Library('ansible-shared-library') _

pipeline {

    agent any

    stages {

        stage('Syntax Validation') {
            steps {
                script {
                    ansibleSyntaxCheck(
                        playbook: 'playbook.yml'
                    )
                }
            }
        }

        stage('Dry Run Validation') {
            steps {
                script {
                    ansiblePlaybookCheck(
                        inventory: 'inventory/dev',
                        playbook: 'playbook.yml'
                    )
                }
            }
        }

        stage('Execute Playbook') {
            steps {
                script {
                    ansiblePlaybook(
                        inventory: 'inventory/dev',
                        playbook: 'playbook.yml'
                    )
                }
            }
        }

    }

}
```

---

# 7. Inputs and Outputs

## Inputs

| Parameter   | Description                                    |
| ----------- | ---------------------------------------------- |
| `playbook`  | Path to the Ansible playbook                   |
| `inventory` | Inventory file used to identify target hosts   |
| `extraArgs` | Additional Ansible CLI arguments               |
| `limit`     | Execute against selected hosts only (optional) |
| `tags`      | Execute selected playbook tags only (optional) |

## Outputs

* Syntax validation report
* Dry-run validation result
* Playbook execution logs
* Jenkins console output
* Pipeline status
* Error messages, if any

---

# 8. Shared Library Structure

For this implementation, the Ansible Playbook CI/CD Shared Library follows the **`src`-based approach**.

The reusable Ansible CI/CD logic is maintained inside Groovy classes under the `src/` directory, while the `vars/` directory provides the pipeline-level entry point.

```text
ansible-shared-library/
│
├── src/
│   └── org/
│       └── company/
│           └── Ansible.groovy
│
├── vars/
│   └── ansible.groovy
│
├── resources/
│
└── README.md
```

### Directory Description

| Directory / File                 | Description                                                                       |
| -------------------------------- | --------------------------------------------------------------------------------- |
| `src/`                           | Contains reusable Groovy classes used by the shared library                       |
| `src/org/company/Ansible.groovy` | Contains reusable Ansible playbook CI/CD logic                                    |
| `vars/`                          | Provides pipeline-level access to shared library functionality                    |
| `vars/ansible.groovy`            | Acts as an entry point between the Jenkins pipeline and the Groovy implementation |
| `resources/`                     | Stores supporting files or templates, if required                                 |
| `README.md`                      | Contains documentation for the shared library                                     |

The main reusable implementation remains inside **`src/`**, which keeps the Ansible pipeline logic organized and separates reusable Groovy logic from pipeline-level access.

---

# 9. Pipeline Workflow

The Jenkins pipeline follows the below workflow:

<img width="1536" height="1024" alt="image" src="https://github.com/user-attachments/assets/dd3d983f-9cbf-4131-bfb0-46949a658623" />

### Workflow Steps

1. Source code changes trigger the Jenkins pipeline.
2. Jenkins loads the Ansible Shared Library.
3. The playbook syntax is validated.
4. The playbook is executed in Check Mode for dry-run validation.
5. If validation succeeds, the playbook is executed.
6. AWS Systems Manager (SSM) is used to securely reach the managed target instances.
7. The playbook is applied to the required target hosts.
8. Jenkins displays the final pipeline status and execution logs.

If any validation or execution stage fails, Jenkins marks the pipeline as failed.

---

# 10. Error Handling

| Error Type             | Example                                      | Resolution                                                          |
| ---------------------- | -------------------------------------------- | ------------------------------------------------------------------- |
| Syntax Error           | Invalid YAML or playbook syntax              | Correct the syntax and rerun the pipeline                           |
| Inventory Error        | Inventory file not found                     | Verify the inventory path                                           |
| SSM Connection Failure | Target instance is not reachable through SSM | Verify SSM Agent status, IAM permissions, and instance connectivity |
| Playbook Failure       | Ansible task execution failed                | Review Jenkins console logs and correct the failed task             |
| Shared Library Error   | Shared library function failed               | Verify the shared library implementation and function usage         |

---

# 11. Example Commands Executed

```bash
# Validate playbook syntax
ansible-playbook --syntax-check playbook.yml

# Dry run validation
ansible-playbook -i inventory playbook.yml --check

# Execute playbook
ansible-playbook -i inventory playbook.yml
```

---

# 12. Conclusion

The Ansible Playbook CI/CD Shared Library centralizes reusable Jenkins pipeline logic for validating and executing Ansible playbooks.

By maintaining common pipeline functionality in a shared library, teams can reduce duplicate Jenkins code, maintain consistency across projects, and simplify Ansible playbook CI/CD workflows.

---

# 13. Contact Information

| Contact Type | Details                                               |
| ------------ | ----------------------------------------------------- |
| Name         | Ankita                                                |
| Role         | DevOps Trainee                                        |
| Email        | [askankita19@gmail.com](mailto:askankita19@gmail.com) |

---

# 14. References

| Description                          | Link                                                              |
| ------------------------------------ | ----------------------------------------------------------------- |
| Official Ansible Documentation       | https://docs.ansible.com/                                         |
| Ansible Playbook Documentation       | https://docs.ansible.com/ansible/latest/playbook_guide/index.html |
| Jenkins Shared Library Documentation | https://www.jenkins.io/doc/book/pipeline/shared-libraries/        |
| Ansible CLI Documentation            | https://docs.ansible.com/ansible/latest/cli/ansible-playbook.html |
| AWS Systems Manager Documentation    | https://docs.aws.amazon.com/systems-manager/                      |
