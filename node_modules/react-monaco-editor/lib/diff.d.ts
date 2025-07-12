import * as React from "react";
import { MonacoDiffEditorProps } from "./types";
declare function MonacoDiffEditor({ width, height, value, defaultValue, language, theme, options, overrideServices, editorWillMount, editorDidMount, editorWillUnmount, onChange, className, original, originalUri, modifiedUri, }: MonacoDiffEditorProps): React.JSX.Element;
declare namespace MonacoDiffEditor {
    var displayName: string;
}
export default MonacoDiffEditor;
