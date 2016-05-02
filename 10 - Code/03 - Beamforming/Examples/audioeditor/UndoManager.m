classdef UndoManager < handle
%UndoManager Manages Undo, Redo operations

%   Copyright 2008 The MathWorks, Inc.
%   Author: Navan Ruthramoorthy

  properties (Access=private)
    UndoData
    CurrentIndex = 1
    hUndoMenu
    hRedoMenu
  end

  methods
      function this = UndoManager()
      end
      function pushData(this, oldData, newData, startIdx, oldEndIdx, newEndIdx)
          this.UndoData{this.CurrentIndex}.OldData = oldData;
          this.UndoData{this.CurrentIndex}.NewData = newData;
          this.UndoData{this.CurrentIndex}.StartIndex = startIdx;
          this.UndoData{this.CurrentIndex}.OldEndIndex = oldEndIdx;
          this.UndoData{this.CurrentIndex}.NewEndIndex = newEndIdx;
          this.CurrentIndex = this.CurrentIndex + 1;
          this.UndoData(this.CurrentIndex:end) = [];
          set(this.hUndoMenu, 'Enable', 'on');
      end
      function [data, startIdx, newEndIdx] = getUndoData(this)
          if this.CurrentIndex > 1
              this.CurrentIndex = this.CurrentIndex - 1;
              data = this.UndoData{this.CurrentIndex}.OldData;
              startIdx = this.UndoData{this.CurrentIndex}.StartIndex;
              newEndIdx = this.UndoData{this.CurrentIndex}.NewEndIndex;
              set(this.hRedoMenu, 'Enable', 'on');
              if this.CurrentIndex <= 1
                  set(this.hUndoMenu, 'Enable', 'off');
              end
          else
              data = [];
              startIdx = [];
              newEndIdx = [];
          end
      end
      function [data, startIdx, oldEndIdx] = getRedoData(this)
          if this.CurrentIndex <= length(this.UndoData)
              data = this.UndoData{this.CurrentIndex}.NewData;
              startIdx = this.UndoData{this.CurrentIndex}.StartIndex;
              oldEndIdx = this.UndoData{this.CurrentIndex}.OldEndIndex;
              this.CurrentIndex = this.CurrentIndex + 1;
              set(this.hUndoMenu, 'Enable', 'on');
              if this.CurrentIndex > length(this.UndoData)
                  set(this.hRedoMenu, 'Enable', 'off');
              end
          else
              data = [];
              startIdx = [];
              oldEndIdx = [];
          end
      end
      function setUndoRedoMenuHandles(this, hUndo, hRedo)
          this.hUndoMenu = hUndo;
          this.hRedoMenu = hRedo;
          set(this.hUndoMenu, 'Enable', 'off');
          set(this.hRedoMenu, 'Enable', 'off');
      end
      function clearUndoData(this)
          this.UndoData = {};
          this.CurrentIndex = 1;
          set(this.hUndoMenu, 'Enable', 'off');
          set(this.hRedoMenu, 'Enable', 'off');
      end
  end

end