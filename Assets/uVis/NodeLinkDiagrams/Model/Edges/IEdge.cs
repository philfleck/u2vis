﻿namespace UVis.NodeLink
{
    public interface IEdge<Node> where Node: class, INode
    {
        int Uid { get; }
        Node Source { get; }
        Node Target { get; }
    }
}
