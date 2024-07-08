# POD
### What is a Pod?

A **Pod** is the smallest and simplest Kubernetes object. It represents a single instance of a running process in your cluster. A Pod can contain one or more containers, which are tightly coupled and share the same network namespace, IP address, and storage volumes.

### Difference Between Pod and Container

- **Pod**:
  - A Pod is a higher-level abstraction that encapsulates one or more containers.
  - It provides shared networking and storage to the containers it holds.
  - It is the unit of deployment, scaling, and replication in Kubernetes.

- **Container**:
  - A container is a lightweight, standalone, executable package that includes everything needed to run a piece of software (code, runtime, system tools, libraries).
  - It is an isolated process on the host operating system.

**In simple terms**: A Pod is like a house (with an address and shared resources) where one or more containers (rooms) live and work together.

