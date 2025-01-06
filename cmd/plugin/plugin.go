// Copyright (C) 2024 stencil-golang contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//        http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package main

import (
	"context"
	"os"

	"github.com/rgst-io/stencil-golang/internal/plugin"
	"go.rgst.io/stencil/v2/pkg/extensions/apiv1"
	"go.rgst.io/stencil/v2/pkg/slogext"
)

// main starts the stencil-golang plugin
func main() {
	ctx := context.Background()
	log := slogext.New()

	if err := apiv1.NewExtensionImplementation(plugin.New(ctx), log); err != nil {
		log.WithError(err).Error("failed to create extension")
		os.Exit(1)
	}
}
