# distributed-computing-data-engineer

This documentation outlines a Docker-based infrastructure for developing a Python framework for distributed computing.
The setup consists of one main node and two worker nodes, all running Ubuntu and capable of communicating with each
other.

```mermaid
graph TD
    subgraph Docker Network
        M[Main Node] <--> W1[Worker Node 1]
        M <--> W2[Worker Node 2]
        W1 <--> W2
    end
    
    subgraph Python Framework
        PM[Python Main Process] --> PM1[Task Distributor]
        PM --> PM2[Result Aggregator]
        PW1[Python Worker Process 1] --> PW11[Task Executor]
        PW2[Python Worker Process 2] --> PW21[Task Executor]
    end
    
    M --> PM
    W1 --> PW1
    W2 --> PW2
```