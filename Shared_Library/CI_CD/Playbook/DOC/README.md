  # Ansible Role & Playbook CI/CD — Shared Library Documentation

<p align="center">
  <img src="https://tcude.net/content/images/size/w2000/2022/01/MainImage-17.png" alt="Ansible" width="250"/>
</p>

---

# Document Details

| **Author** | **Created on** | **Version** | **Last Updated By** | **Last Edited On** | **Pre Reviewer** | **L0 Reviewer** | **L1 Reviewer** | **L2 Reviewer** |
| ---------- | -------------- | ----------- | ------------------- | ------------------ | ---------------- | --------------- | --------------- | --------------- |
| Ankita     | 20-07-2026     | v1.0        | Ankita              | 20-07-2026         | Team             | Komal Jaiswal   | Akshit Kapil    | Mahesh Kumar    |

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

Ansible is an open-source automation tool used for configuration management, application deployment, and infrastructure provisioning.

To avoid repeating the same pipeline logic across multiple Jenkins projects, common Ansible operations are implemented inside a Jenkins Shared Library. Instead of writing identical stages in every Jenkinsfile, projects can simply invoke reusable shared library functions.

This approach simplifies pipeline development, improves consistency, and reduces maintenance effort.

---

# 2. What is the Ansible CI/CD Shared Library?

The Ansible CI/CD Shared Library is a reusable Jenkins library that contains common pipeline functions for validating and executing Ansible playbooks.

Rather than implementing the same Ansible commands in every Jenkins pipeline, these functions are written once and reused across multiple repositories.

The library provides reusable functions to:

* Validate Ansible playbook syntax
* Execute playbooks
* Perform dry-run validation
* Standardize CI/CD pipelines
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
* Centralizes updates in one location.

---

# 4. Prerequisites

Before using the shared library, ensure the following components are available.

| Tool                   | Purpose                       |
| ---------------------- | ----------------------------- |
| Jenkins                | CI/CD Server                  |
| Jenkins Shared Library | Reusable pipeline functions   |
| Git                    | Source Code Management        |
| Python 3.10+           | Required by Ansible           |
| Ansible                | Configuration Management Tool |
| SSH Credentials        | Connect to managed hosts      |
| Inventory File         | Target host definitions       |
| Ansible Playbook       | Deployment automation         |

---

# 5. Supported Shared Library Functions

The shared library exposes reusable pipeline functions that can be invoked directly from Jenkins pipelines.

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
* Simulates execution
* Detects possible failures
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

    }

}
```

---

# 7. Inputs and Outputs

## Inputs

| Parameter   | Description                               |
| ----------- | ----------------------------------------- |
| `playbook`  | Path to the Ansible playbook              |
| `inventory` | Inventory file                            |
| `extraArgs` | Additional Ansible CLI arguments          |
| `limit`     | Execute against selected hosts (optional) |
| `tags`      | Execute selected tags only (optional)     |

## Outputs

* Syntax validation report
* Playbook execution logs
* Jenkins console output
* Pipeline status
* Error messages (if any)

---

# 8. Shared Library Structure

The shared library is organized into dedicated directories for better maintainability.

```text
ansible-shared-library/

├── vars/
│   ├── ansibleSyntaxCheck.groovy
│   ├── ansiblePlaybook.groovy
│   └── ansiblePlaybookCheck.groovy
│
├── src/
│   └── org/
│       └── company/
│           └── Ansible.groovy
│
├── resources/
│
└── README.md
```

### Directory Description

| Directory  | Description                          |
| ---------- | ------------------------------------ |
| vars/      | Global pipeline functions            |
| src/       | Reusable Groovy classes              |
| resources/ | Supporting files used by the library |
| README.md  | Project documentation                |

---

# 9. Pipeline Workflow

The Jenkins pipeline performs the following steps:

1. Checkout source code.
2. Load the Jenkins Shared Library.
3. Validate the Ansible playbook syntax.
4. Execute the Ansible playbook.
5. Perform a dry-run validation.
6. Display pipeline status.

If any stage fails, Jenkins immediately stops the pipeline and marks the build as failed.

---

# 10. Error Handling

| Error Type             | Example                         | Resolution                                   |
| ---------------------- | ------------------------------- | -------------------------------------------- |
| Syntax Error           | Invalid YAML or playbook syntax | Correct the syntax and rerun the pipeline    |
| Inventory Error        | Inventory file not found        | Verify inventory path                        |
| Authentication Failure | SSH connection failed           | Check SSH credentials and permissions        |
| Playbook Failure       | Task execution failed           | Review Jenkins console logs and fix the task |
| Shared Library Error   | Function execution failed       | Verify shared library configuration          |

---

# 11. Example Commands Executed

```bash
# Validate playbook syntax
ansible-playbook --syntax-check playbook.yml

# Execute playbook
ansible-playbook -i inventory playbook.yml

# Dry run validation
ansible-playbook -i inventory playbook.yml --check
```

---

# 12. Conclusion

The Ansible Role & Playbook CI/CD Shared Library centralizes reusable Jenkins pipeline logic for validating and executing Ansible playbooks. By moving common pipeline functionality into a shared library, teams can build consistent, maintainable, and scalable CI/CD pipelines while reducing duplicate code and simplifying Jenkinsfiles.

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
