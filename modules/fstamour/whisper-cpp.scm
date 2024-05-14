;; -*- compile-command: "./guix build whisper-cpp -K"; -*-

;; Tips:
;; - use--no-substitute to save a bit of time
;; - https://guix.gnu.org/manual/en/html_node/Debugging-Build-Failures.html
;; - ./guix shell whisper-cpp

(define-module (fstamour whisper-cpp)
  #:use-module (guix)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages)
  #:use-module (guix build-system cmake)
  #:use-module (guix git-download)
  #:use-module (gnu packages pkg-config)
  ;; For openblas
  #:use-module (gnu packages maths))

;; TODO both llama-cpp (already packaged in guix), and whisper-cpp
;; uses ggml and both (IIRC) vendors ggml in their repo. It would be
;; nice to be able to compile it only once.

;; TODO build the "command" example (requires sdl)
;; TODO build the "stream" example (requires sdl)
;; TODO _maybe_ build the "talk" example (also requires sdl)
(define-public whisper-cpp
  (package
    (name "whisper-cpp")
    (version "1.5.5")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/ggerganov/whisper.cpp")
             (commit "v1.5.5")))
       (file-name (git-file-name name version))
       (sha256 (base32 "1a91nbpx9x7sr8ivnycwdqz5ha1w1kygpk6brbis97mx77xin123"))
       ;; TODO ignore examples/ .devops/ samples/ .github/ bindings/{go,ruby,java}
       ))
    (build-system cmake-build-system)
    (arguments
     (list
      #:tests? #f
      #:configure-flags #~'("-DCMAKE_BUILD_WITH_INSTALL_RPATH=TRUE"

                            "-DWHISPER_BLAS=ON"
                            "-DWHISPER_BLAS_VENDOR=OpenBLAS"

                            ;; TODO "-DWHISPER_CUDA=ON"

                            ;; "-DWHISPER_BUILD_TESTS=ON"
                            "-DWHISPER_BUILD_EXAMPLES=ON")

      #:modules '((ice-9 textual-ports)
                  (guix build utils)
                  (guix build cmake-build-system))
      #:imported-modules `(,@%cmake-build-system-modules)
      #:phases
      #~(modify-phases %standard-phases
          (replace 'build
            (lambda _
              (apply invoke "make"
                     `("main"
                       "-j" ,(number->string (parallel-job-count))))))
          (add-after 'install 'install-main
            (lambda _
              (mkdir-p (string-append #$output "/bin/"))
              (copy-file "bin/main" (string-append #$output "/bin/whisper"))))

          ;; (add-after 'install 'fuck-around (lambda (_) (exit 42)))
          )))
    (native-inputs (list pkg-config))
    (propagated-inputs
     (list openblas))
    (properties '((tunable? . #true))) ;use AVX512, FMA, etc. when available

    (home-page "https://github.com/ggerganov/whisper.cpp")
    (synopsis "Port of OpenAI's Whisper model in C/C++")
    (description "High-performance inference of OpenAI's Whisper automatic speech recognition (ASR) model:

- Plain C/C++ implementation without dependencies
- Apple Silicon first-class citizen - optimized via ARM NEON, Accelerate framework, Metal and Core ML
- AVX intrinsics support for x86 architectures
- VSX intrinsics support for POWER architectures
- Mixed F16 / F32 precision
- 4-bit and 5-bit integer quantization support
- Zero memory allocations at runtime
- Support for CPU-only inference
- Efficient GPU support for NVIDIA
- Partial OpenCL GPU support via CLBlast
- OpenVINO Support
- C-style API")
    (license license:expat)))

;; WIP Common lisp bindings...
;; (define-public sbcl-whisper-cpp
;;   (package
;;     (name "sbcl-whisper")
;;     (version "0.0.1")
;;     `((in-package :whisper)
;;       (cffi:define-foreign-library
;;        libwhisper
;;        (t (:default ,(search-input-file inputs "/lib/libwhisper.so")))))))

;; This allows you to run guix shell -f guix-packager.scm.
;; Remove this line if you just want to define a package.
whisper-cpp
