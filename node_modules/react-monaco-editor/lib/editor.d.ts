import * as React from "react";
import { MonacoEditorProps } from "./types";
declare function MonacoEditor({ width, height, value, defaultValue, language, theme, options, overrideServices, editorWillMount, editorDidMount, editorWillUnmount, onChange, className, uri, }: MonacoEditorProps): React.JSX.Element;
declare namespace MonacoEditor {
    var displayName: string;
}
export default MonacoEditor;
