//
//  TemplateNode.swift
//  Meli FFI Mobile Application
//
//  Created by mohamede1945 on 6/19/15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import Foundation

/**
Represents the template node class.

@author mohamede1945

@version 1.0
*/
public class TemplateNode {

    /// Represents the name property.
    let name: String

    /// Represents the parent property.
    weak var parent: TemplateNode?

    /// Represents the children property.
    var children: [TemplateNode] = []

    /**
    Initialize new instance with name.

    - parameter name: The name parameter.

    - returns: The new created instance.
    */
    init(name: String) {
        self.name = name
    }

    /**
    Add child node.

    - parameter child: The child parameter.
    */
    func addChildNode(child: TemplateNode) {
        children.append(child)
        child.parent = self
    }
    
    /**
    Add child node At Particular Index.

    - parameter child: The child parameter.
    */
    func addChildNodeAtIndex(child: TemplateNode, index: Int) {
        children.insert(child, atIndex: index)
        child.parent = self
    }
    
    //Added
    func removeChildNode() {
        children.removeAll(keepCapacity: true)
    }
    //End of Addition
    /**
    Get template branch names.

    - returns: the names of the branch.
    */
    func getTemplateBranchNames() -> [String] {
        var branchNames: [String] = []
        addName(&branchNames)
        return branchNames
    }

    /**
    Add name to the branch.

    - parameter branchNames: The branch names parameter.
    */
    func addName(inout branchNames: [String]) {
        branchNames.insert(name, atIndex: 0)
        parent?.addName(&branchNames)
    }

    /**
    Get a sorted children by name.

    - returns: the sorted children by name.
    */
    func sortedChildren() -> [TemplateNode] {
        return children.sort { $0.isOrderedBefore($1) }
    }

    /**
    Is generic template.

    - returns: Always false.
    */
    func isGenericTemplate() -> Bool {
        return false
    }

    /**
    Is ordered before.

    - parameter node: The node parameter.

    - returns: true if current is before the node.
    */
    func isOrderedBefore(node: TemplateNode) -> Bool {
        if isGenericTemplate() {
            return true
        }
        if node.isGenericTemplate() {
            return false
        }

        return name.caseInsensitiveCompare(node.name) == .OrderedAscending
    }
}

extension TemplateNode : CustomStringConvertible
{
    /// Represents the description property.
    public var description: String {
        return "\(self.dynamicType): {name: \(name)"
    }
}